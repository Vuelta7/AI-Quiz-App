import 'package:do_not_disturb/do_not_disturb_plugin.dart';
import 'package:do_not_disturb/types.dart';
import 'package:flutter/material.dart';

class DoNotDisturbPage extends StatefulWidget {
  const DoNotDisturbPage({super.key});

  @override
  State<DoNotDisturbPage> createState() => _DoNotDisturbPageState();
}

class _DoNotDisturbPageState extends State<DoNotDisturbPage> {
  final _dndPlugin = DoNotDisturbPlugin();

  @override
  void initState() {
    super.initState();
  }

  bool _isDndEnabled = false;
  bool _notifPolicyAccess = false;
  InterruptionFilter _dndStatus = InterruptionFilter.unknown;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Do not Disturb Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: _checkDndEnabled,
              child: const Text('Check if DND is Enabled'),
            ),
            const SizedBox(height: 10),
            Text('DND Enabled: $_isDndEnabled'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getDndStatus,
              child: const Text('Get DND Status'),
            ),
            const SizedBox(height: 10),
            Text('DND Status: ${_dndStatus.toString()}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openDndSettings,
              child: const Text('Open DND Settings'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _checkNotificationPolicyAccessGranted,
              child:
                  const Text('Check if Notification Policy Access is Granted'),
            ),
            const SizedBox(height: 10),
            Text('Notification Policy Access : $_notifPolicyAccess'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _openNotificationPolicyAccessSettings,
              child: const Text('Open Notification Policy Access Settings'),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () async {
                await _checkNotificationPolicyAccessGranted();
                await Future.delayed(const Duration(milliseconds: 50));
                if (!_notifPolicyAccess) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: const Text(
                          'Notification Policy Access not granted')));
                  return;
                }
                if (_isDndEnabled) {
                  _setInterruptionFilter(InterruptionFilter.all);
                } else {
                  _setInterruptionFilter(InterruptionFilter.alarms);
                }
              },
              child: const Text('Toggle DND/Zen mode'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _checkNotificationPolicyAccessGranted() async {
    try {
      final bool isNotificationPolicyAccessGranted =
          await _dndPlugin.isNotificationPolicyAccessGranted();
      setState(() {
        _notifPolicyAccess = isNotificationPolicyAccessGranted;
      });
    } catch (e) {
      print('Error checking notification policy access: $e');
    }
  }

  Future<void> _checkDndEnabled() async {
    try {
      final bool isDndEnabled = await _dndPlugin.isDndEnabled();
      setState(() {
        _isDndEnabled = isDndEnabled;
      });
    } catch (e) {
      print('Error checking DND status: $e');
    }
  }

  Future<void> _getDndStatus() async {
    try {
      final InterruptionFilter status = await _dndPlugin.getDNDStatus();
      setState(() {
        _dndStatus = status;
      });
    } catch (e) {
      print('Error getting DND status: $e');
    }
  }

  Future<void> _openDndSettings() async {
    try {
      await _dndPlugin.openDndSettings();
    } catch (e) {
      print('Error opening DND settings: $e');
    }
  }

  Future<void> _openNotificationPolicyAccessSettings() async {
    try {
      await _dndPlugin.openNotificationPolicyAccessSettings();
    } catch (e) {
      print('Error opening notification policy access settings: $e');
    }
  }

  Future<void> _setInterruptionFilter(InterruptionFilter filter) async {
    try {
      await _dndPlugin.setInterruptionFilter(filter);
      _checkDndEnabled();
      _getDndStatus();
    } catch (e) {
      print('Error setting interruption filter: $e');
    }
  }
}
