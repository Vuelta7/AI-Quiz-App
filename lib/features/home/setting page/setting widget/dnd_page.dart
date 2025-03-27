import 'package:do_not_disturb/do_not_disturb_plugin.dart';
import 'package:do_not_disturb/types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:lottie/lottie.dart';

class DoNotDisturbPage extends ConsumerStatefulWidget {
  const DoNotDisturbPage({super.key});

  @override
  ConsumerState<DoNotDisturbPage> createState() => _DoNotDisturbPageState();
}

class _DoNotDisturbPageState extends ConsumerState<DoNotDisturbPage>
    with WidgetsBindingObserver {
  final _dndPlugin = DoNotDisturbPlugin();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkNotificationPolicyAccessGranted();
    _checkDndEnabled();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  bool _isDndEnabled = false;
  bool _notifPolicyAccess = false;

  @override
  Widget build(BuildContext context) {
    final userColor = ref.watch(userColorProvider);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: getShade(userColor, 300),
        title: Text(
          'DND Settings',
          style: TextStyle(
            color: userColor,
            fontFamily: 'PressStart2P',
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: userColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: userColor,
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
                  getShade(userColor, 300),
                  () async {
                    await _openNotificationPolicyAccessSettings();
                    await Future.delayed(
                      const Duration(seconds: 4),
                    );
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DoNotDisturbPage(),
                        ),
                      );
                    }
                  },
                ),
              if (_notifPolicyAccess)
                buildRetroButton(
                  'Toggle DND mode',
                  getShade(userColor, 300),
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
      _checkNotificationPolicyAccessGranted();
      _checkDndEnabled();
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
