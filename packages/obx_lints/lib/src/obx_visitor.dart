part of '../obx_lints.dart';

class _ObxVisitor extends RecursiveAstVisitor<void> {
  final ResolvedUnitResult unitResult;
  final List<ObxIssue> issues;
  final Map<InterfaceElement, _TypeKind> typeKinds;

  _ObxVisitor(this.unitResult, this.issues, this.typeKinds);

  static final _reactiveNameRegex = RegExp(r'[a-z0-9]R$|(?<!on)Reactive');
  static const _kCounterpartNames = {'value': 'valueR', 'valueF': 'valueRF', 'valueR': 'value', 'valueRF': 'valueF'};
  static const _kReactiveReadNames = {'valueR', 'valueRF'};

  _ObxScope _scope = _ObxScope.plain;
  _IgnoredCodes? _ignoredCodes;
  bool? _isToggleAccessible;

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final parentScope = _scope;
    _scope = _declarationScope(node.name.lexeme);
    super.visitMethodDeclaration(node);
    _scope = parentScope;
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final name = node.name.lexeme;
    final isLocal = node.parent is FunctionDeclarationStatement;
    final parentScope = _scope;
    _scope = isLocal ? _localFunctionScope(name) : _declarationScope(name);
    super.visitFunctionDeclaration(node);
    _scope = parentScope;
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    if (node.parent is FunctionDeclaration) {
      super.visitFunctionExpression(node);
      return;
    }
    final parentScope = _scope;
    _scope = _closureScope(node);
    super.visitFunctionExpression(node);
    _scope = parentScope;
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    _checkValueRead(node.prefix, node.identifier);
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    _checkValueRead(node.realTarget, node.propertyName);
    super.visitPropertyAccess(node);
  }

  @override
  void visitConditionalExpression(ConditionalExpression node) {
    if (_isReactiveSwitch(node)) {
      node.condition.accept(this);
      return;
    }
    super.visitConditionalExpression(node);
  }

  @override
  void visitAssignmentExpression(AssignmentExpression node) {
    final toggleTargetSource = _toggleTargetSourceOf(node);
    if (toggleTargetSource == null) {
      super.visitAssignmentExpression(node);
      return;
    }
    _report(node, ObxRule.preferRxToggle, replacement: '$toggleTargetSource.toggle()');
  }

  _ObxScope _declarationScope(String name) {
    if (_reactiveNameRegex.hasMatch(name)) return _ObxScope.reactive;
    return _ObxScope.plain;
  }

  /// a local function might be a sync helper or a callback, so it only stays reactive when named so.
  _ObxScope _localFunctionScope(String name) {
    if (_reactiveNameRegex.hasMatch(name)) return _ObxScope.reactive;
    final currentScope = _scope;
    return currentScope == _ObxScope.reactive ? _ObxScope.neutral : currentScope;
  }

  /// obx builders are reactive, callbacks of collections/Rx methods run within the current build,
  /// widget callbacks run outside of it, and any other callback might run in either.
  _ObxScope _closureScope(FunctionExpression node) {
    final currentScope = _scope;
    final isReactive = currentScope == _ObxScope.reactive;
    final unknownTimingScope = isReactive ? _ObxScope.neutral : currentScope;
    final argument = node.parent;
    final argumentList = argument is NamedArgument ? argument.parent : argument;
    if (argumentList is! ArgumentList) return unknownTimingScope;

    final invocation = argumentList.parent;
    if (invocation is InstanceCreationExpression) {
      final kind = _kindOf(invocation.staticType);
      final isObxBuilder = kind == _TypeKind.obx && argument is! NamedArgument;
      if (isObxBuilder) return _ObxScope.reactive;
      if (kind == _TypeKind.obx || kind == _TypeKind.widget) return isReactive ? _ObxScope.plain : currentScope;
      if (kind == _TypeKind.collection) return currentScope;
    } else if (invocation is MethodInvocation) {
      final targetType = invocation.realTarget?.staticType;
      final kind = _kindOf(targetType);
      if (kind.hasSyncCallbacks) return currentScope;
    }
    return unknownTimingScope;
  }

  void _checkValueRead(Expression target, SimpleIdentifier property) {
    final scope = _scope;
    if (scope == _ObxScope.neutral) return;
    final name = property.name;
    final counterpartName = _kCounterpartNames[name];
    if (counterpartName == null) return;
    if (property.inSetterContext()) return;

    final kind = _kindOf(target.staticType);
    final isReactiveRead = _kReactiveReadNames.contains(name);
    if (scope == _ObxScope.reactive) {
      if (kind == _TypeKind.reactiveRx && !isReactiveRead) {
        _report(property, ObxRule.nonReactiveValueInsideObx, replacement: counterpartName);
      } else if (kind == _TypeKind.nonReactiveRx && isReactiveRead) {
        _report(property, ObxRule.nonReactiveRxInsideObx);
      }
    } else if (isReactiveRead) {
      // -- switching a reactive Rx to `value` is left manual, the enclosing method might be called from an `Obx` build.
      if (kind == _TypeKind.reactiveRx) {
        _report(property, ObxRule.avoidReactiveValueOutsideObx);
      } else if (kind == _TypeKind.nonReactiveRx) {
        _report(property, ObxRule.avoidReactiveValueOutsideObx, replacement: counterpartName);
      }
    }
  }

  /// `reactive ? rx.valueR : rx.value`
  bool _isReactiveSwitch(ConditionalExpression node) {
    final thenRead = _valueReadOf(node.thenExpression);
    if (thenRead == null) return false;
    final elseRead = _valueReadOf(node.elseExpression);
    if (elseRead == null) return false;
    final thenCounterpartName = _kCounterpartNames[thenRead.name];
    if (thenCounterpartName != elseRead.name) return false;
    final thenTargetSource = _sourceOf(thenRead.target);
    final elseTargetSource = _sourceOf(elseRead.target);
    return thenTargetSource == elseTargetSource;
  }

  String? _toggleTargetSourceOf(AssignmentExpression node) {
    if (node.operator.type != TokenType.EQ) return null;
    final negation = node.rightHandSide.unParenthesized;
    if (negation is! PrefixExpression || negation.operator.type != TokenType.BANG) return null;
    final assignedRead = _valueReadOf(node.leftHandSide);
    if (assignedRead == null || assignedRead.name != 'value') return null;
    final negatedOperand = negation.operand.unParenthesized;
    final negatedRead = _valueReadOf(negatedOperand);
    if (negatedRead == null) return null;
    final negatedName = negatedRead.name;
    if (negatedName != 'value' && negatedName != 'valueR') return null;
    final target = assignedRead.target;
    if (!_isRxBool(target.staticType)) return null;

    final targetSource = _sourceOf(target);
    final negatedTargetSource = _sourceOf(negatedRead.target);
    if (targetSource != negatedTargetSource) return null;
    final isToggleAccessible = _isToggleAccessible ??= _checkToggleAccessible();
    if (!isToggleAccessible) return null;
    return targetSource;
  }

  bool _checkToggleAccessible() {
    for (final extension in unitResult.libraryFragment.accessibleExtensions) {
      if (extension.getMethod('toggle') != null) return true;
    }
    return false;
  }

  String _sourceOf(AstNode node) => unitResult.content.substring(node.offset, node.end);

  _TypeKind _kindOf(DartType? type) {
    if (type is! InterfaceType) return _TypeKind.other;
    final element = type.element;
    return typeKinds[element] ??= _classify(element);
  }

  void _report(AstNode node, ObxRule rule, {String? replacement}) {
    final offset = node.offset;
    final lineInfo = unitResult.lineInfo;
    final location = lineInfo.getLocation(offset);
    final lineNumber = location.lineNumber;
    final ignoredCodes = _ignoredCodes ??= _IgnoredCodes.parse(unitResult.content, lineInfo);
    if (ignoredCodes.isIgnored(rule, lineNumber)) return;
    issues.add(
      ObxIssue(
        path: unitResult.path,
        line: lineNumber,
        column: location.columnNumber,
        offset: offset,
        length: node.length,
        rule: rule,
        replacement: replacement,
      ),
    );
  }

  static _ValueRead? _valueReadOf(Expression node) {
    if (node is PrefixedIdentifier) return (target: node.prefix, name: node.identifier.name);
    if (node is PropertyAccess && !node.isCascaded) return (target: node.realTarget, name: node.propertyName.name);
    return null;
  }

  static bool _isRxBool(DartType? type) {
    if (type is! InterfaceType) return false;
    final rxBaseType = _findSupertype(type, 'RxBase');
    if (rxBaseType == null) return false;
    final valueType = rxBaseType.typeArguments.single;
    return valueType.isDartCoreBool && valueType.nullabilitySuffix == NullabilitySuffix.none;
  }

  static InterfaceType? _findSupertype(InterfaceType type, String name) {
    if (type.element.name == name) return type;
    for (final supertype in type.allSupertypes) {
      if (supertype.element.name == name) return supertype;
    }
    return null;
  }

  static _TypeKind _classify(InterfaceElement element) {
    final supertypes = element.allSupertypes;
    final names = <String?>{element.name, for (final supertype in supertypes) supertype.element.name};
    if (names.contains('Obx')) return _TypeKind.obx;
    if (names.contains('Widget')) return _TypeKind.widget;
    if (names.contains('RxUpdatersMixin')) return _TypeKind.reactiveRx;
    if (names.contains('RxOUpdatersMixin')) return _TypeKind.nonReactiveRx;
    if (names.contains('RxBaseCore')) return _TypeKind.undeterminedRx;
    final thisType = element.thisType;
    if (thisType.isDartCoreIterable || thisType.isDartCoreMap) return _TypeKind.collection;
    for (final supertype in supertypes) {
      if (supertype.isDartCoreIterable || supertype.isDartCoreMap) return _TypeKind.collection;
    }
    return _TypeKind.other;
  }
}

class _IgnoredCodes {
  final Set<String> fileCodes;
  final Map<int, Set<String>> lineCodes;

  const _IgnoredCodes(this.fileCodes, this.lineCodes);

  static final _ignoreForFileRegex = RegExp(r'//\s*ignore_for_file:([\w ,]+)');
  static final _ignoreRegex = RegExp(r'//\s*ignore:([\w ,]+)');

  /// same placement as analyzer ignores: a comment on its own line covers the next line, a trailing one covers its line.
  factory _IgnoredCodes.parse(String content, LineInfo lineInfo) {
    final fileCodes = <String>{};
    for (final match in _ignoreForFileRegex.allMatches(content)) {
      final codes = _splitCodes(match.group(1)!);
      fileCodes.addAll(codes);
    }

    final lineCodes = <int, Set<String>>{};
    for (final match in _ignoreRegex.allMatches(content)) {
      final commentOffset = match.start;
      final lineNumber = lineInfo.getLocation(commentOffset).lineNumber;
      final lineOffset = lineInfo.getOffsetOfLine(lineNumber - 1);
      final isOwnLine = content.substring(lineOffset, commentOffset).trim().isEmpty;
      final coveredLineNumber = isOwnLine ? lineNumber + 1 : lineNumber;
      final codes = _splitCodes(match.group(1)!);
      (lineCodes[coveredLineNumber] ??= {}).addAll(codes);
    }
    return _IgnoredCodes(fileCodes, lineCodes);
  }

  static Iterable<String> _splitCodes(String codes) => codes.split(',').map((code) => code.trim());

  bool isIgnored(ObxRule rule, int lineNumber) {
    final code = rule.code;
    if (fileCodes.contains(code)) return true;
    return lineCodes[lineNumber]?.contains(code) == true;
  }
}

enum _ObxScope {
  /// regular code, `valueR` isn't reactive here.
  plain,

  /// callbacks and local functions that might run in either, nothing is reported.
  neutral,

  /// `Obx` builders and `...R`/`...Reactive` getters/methods, reads are expected to be reactive.
  reactive,
}

enum _TypeKind {
  other(false),
  obx(false),
  widget(false),
  collection(true),
  reactiveRx(true),
  nonReactiveRx(true),
  undeterminedRx(true),
  ;

  final bool hasSyncCallbacks;

  const _TypeKind(this.hasSyncCallbacks);
}

typedef _ValueRead = ({Expression target, String name});
