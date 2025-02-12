import 'package:do_not_disturb/do_not_disturb_plugin.dart';
import 'package:do_not_disturb/types.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/utils/color_utils.dart';
import 'package:learn_n/utils/retro_button.dart';
import 'package:lottie/lottie.dart';

class DoNotDisturbPage extends StatefulWidget {
  final Color color;
  const DoNotDisturbPage({super.key, required this.color});

  @override
  State<DoNotDisturbPage> createState() => _DoNotDisturbPageState();
}

// TODO: fix mechanics
class _DoNotDisturbPageState extends State<DoNotDisturbPage> {
  final _dndPlugin = DoNotDisturbPlugin();

  @override
  void initState() {
    super.initState();
    _checkNotificationPolicyAccessGranted();
    _checkDndEnabled();
  }

  bool _isDndEnabled = false;
  bool _notifPolicyAccess = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getShade(widget.color, 300),
        title: Text(
          'DND Settings',
          style: TextStyle(
            color: widget.color,
            fontFamily: 'PressStart2P',
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: widget.color,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: widget.color,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Lottie.asset('assets/dnd.json'),
              const SizedBox(height: 20),
              Text(
                _notifPolicyAccess
                    ? 'DND mode is ${_isDndEnabled ? 'enabled' : 'disabled'}'
                    : 'App is not allowed to access DND settings. To enable DND mode, give the app access to DND settings.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PressStart2P',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              if (!_notifPolicyAccess)
                buildRetroButton(
                  'Open Notification Policy Access Settings',
                  getShade(widget.color, 300),
                  _openNotificationPolicyAccessSettings,
                ),
              if (_notifPolicyAccess)
                buildRetroButton(
                  'Toggle DND mode',
                  Colors.teal[300]!,
                  () async {
                    await _checkNotificationPolicyAccessGranted();
                    await Future.delayed(const Duration(milliseconds: 50));
                    if (!_notifPolicyAccess) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content:
                              Text('Notification Policy Access not granted')));
                      return;
                    }
                    if (_isDndEnabled) {
                      _setInterruptionFilter(InterruptionFilter.all);
                    } else {
                      _setInterruptionFilter(InterruptionFilter.alarms);
                    }
                  },
                ),
            ],
          ),
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
    } catch (e) {
      print('Error setting interruption filter: $e');
    }
  }
}
