# obx_lints

On-demand command line checks for nampack `Obx`/`Rx` usage. Nothing runs in the IDE or the analysis server.

## Setup

```sh
cd packages/obx_lints
dart pub get
dart compile exe bin/obx_lints.dart -o build/obx_lints.exe
```

Recompile after changing the rules. `dart run bin/obx_lints.dart` works without compiling but is ~4x slower.

## Usage

From a project root:

```sh
obx_lints.exe             # checks lib
obx_lints.exe lib/ui a.dart
obx_lints.exe --fix       # applies safe fixes in place
```

Exits with 1 while issues remain. The analysis cache lives in `.dart_tool/obx_lints`.

| code | reports | fix |
| --- | --- | --- |
| `non_reactive_value_inside_obx` | `value`/`valueF` of a reactive Rx inside an `Obx` builder or a `...R`/`...Reactive` getter/method | `valueR`/`valueRF` |
| `avoid_rx_value_getter_outside_obx` | `valueR`/`valueRF` anywhere else | `value`, for `RxO` types only |
| `non_reactive_rx_inside_obx` | `valueR` of an `RxO` type inside an `Obx` builder | manual |
| `prefer_rx_toggle` | `x.value = !x.value` | `x.toggle()` |

Callbacks of collection/Rx methods (`map`, `where`, ..) count as part of the `Obx` build, widget callbacks (`onTap`, other builders) don't,
other callbacks and local functions are skipped. Silence with `// ignore: <code>` or `// ignore_for_file: <code>`.

VS Code task that fills the Problems panel:

```json
{
  "label": "obx_lints",
  "type": "shell",
  "command": "path/to/obx_lints.exe",
  "problemMatcher": {
    "owner": "obx_lints",
    "fileLocation": ["relative", "${workspaceFolder}"],
    "severity": "warning",
    "pattern": { "regexp": "^(.+?):(\\d+):(\\d+) - (.+) - (\\w+)", "file": 1, "line": 2, "column": 3, "message": 4, "code": 5 }
  }
}
```

## Runtime check

Run or build with `--dart-define=NAMPACK_HIGHLIGHT_NON_REACTIVE_OBX=true` to overlay `!! NON-REACTIVE !!` on every `Obx` that subscribed to nothing.
It catches what static checks can't see (reads inside helper calls, `RxBaseCore`-typed fields) and compiles out when the define is absent.
