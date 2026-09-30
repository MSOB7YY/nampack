import 'stubs.dart';

class Sample {
  final count = Rx<int>(0);
  final countO = RxO<int>(0);
  final isOn = Rx<bool>(false);
  final items = Rx<List<int>>([]);

  int get countPlain => count.valueR; // expect: avoid_rx_value_getter_outside_obx
  int get countR => count.value; // expect: non_reactive_value_inside_obx
  int readCountR() => count.valueR;
  int readCountReactive() => count.valueR;

  int readCount() => count.valueR; // expect: avoid_rx_value_getter_outside_obx
  int readCountO() => countO.valueR; // expect: avoid_rx_value_getter_outside_obx
  int readSwitch({required bool reactive}) => reactive ? count.valueR : count.value;

  void flip() {
    isOn.value = !isOn.value; // expect: prefer_rx_toggle
    isOn.value = !isOn.valueR; // expect: prefer_rx_toggle
    count.value = count.value + 1;
  }

  void ignored() {
    // ignore: avoid_rx_value_getter_outside_obx
    count.valueR;
    count.valueR; // ignore: avoid_rx_value_getter_outside_obx
  }

  Widget build(BuildContext context) {
    return Obx(
      (context) {
        final a = count.valueR;
        final b = count.value; // expect: non_reactive_value_inside_obx
        final c = countO.valueR; // expect: non_reactive_rx_inside_obx
        final d = countO.value;
        final e = items.valueR.map((i) => i + count.value); // expect: non_reactive_value_inside_obx
        int localHelper() => count.value;
        return GestureDetector(
          onTap: () => count.valueR, // expect: avoid_rx_value_getter_outside_obx
          child: Text('$a $b $c $d $e ${localHelper()} ${count.value}',), // expect: non_reactive_value_inside_obx
        );
      },
    );
  }
}
