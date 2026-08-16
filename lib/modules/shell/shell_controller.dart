import 'package:get/get.dart' hide Value;

/// The bottom-nav destinations, in bar order.
///
/// An enum rather than a bare index so the tab a caller wants is named at the
/// call site — `shell.go(ShellTab.map)` rather than `shell.index.value = 2`.
enum ShellTab { home, fuel, map, stats }

/// Which tab the shell is showing.
///
/// Permanent, because the home screen's section cards switch tabs and the
/// shell outlives any single route.
class ShellController extends GetxController {
  final tab = ShellTab.home.obs;

  int get index => tab.value.index;

  void go(ShellTab next) => tab.value = next;

  void goToIndex(int next) => tab.value = ShellTab.values[next];
}
