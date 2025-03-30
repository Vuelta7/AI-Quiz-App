import 'package:do_not_disturb/do_not_disturb_plugin.dart';
import 'package:do_not_disturb/types.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dndProvider = ChangeNotifierProvider((ref) => DndController());

class DndController extends ChangeNotifier with WidgetsBindingObserver {
  final _dndPlugin = DoNotDisturbPlugin();
  bool _notifPolicyAccess = false;
  bool _isDndEnabled = false;

  DndController() {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  Future<void> _initialize() async {
    await _checkNotificationPolicyAccessGranted();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disableDnd();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _enableDnd();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _disableDnd();
    }
  }

  Future<void> _checkNotificationPolicyAccessGranted() async {
    _notifPolicyAccess = await _dndPlugin.isNotificationPolicyAccessGranted();
    notifyListeners();
  }

  Future<void> _enableDnd() async {
    if (_notifPolicyAccess) {
      await _dndPlugin.setInterruptionFilter(InterruptionFilter.alarms);
      _isDndEnabled = true;
      notifyListeners();
    }
  }

  Future<void> _disableDnd() async {
    await _dndPlugin.setInterruptionFilter(InterruptionFilter.all);
    _isDndEnabled = false;
    notifyListeners();
  }

  // ✅ Getter methods for UI access
  bool get notifPolicyAccess => _notifPolicyAccess;
  bool get isDndEnabled => _isDndEnabled;

  Future<void> toggleDnd() async {
    if (_isDndEnabled) {
      await _disableDnd();
    } else {
      await _enableDnd();
    }
  }

  Future<void> openNotificationPolicyAccessSettings() async {
    await _dndPlugin.openNotificationPolicyAccessSettings();
  }
}
