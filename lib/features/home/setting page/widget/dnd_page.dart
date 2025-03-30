import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learn_n/core/provider/dnd_provider.dart';
import 'package:learn_n/core/utils/user_color_provider.dart';
import 'package:learn_n/core/widgets/retro_button.dart';
import 'package:lottie/lottie.dart';

class DoNotDisturbPage extends ConsumerWidget {
  const DoNotDisturbPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userColor = ref.watch(userColorProvider);
    final dndController = ref.watch(dndProvider);

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
                dndController.notifPolicyAccess
                    ? 'DND mode is ${dndController.isDndEnabled ? 'enabled' : 'disabled'}'
                    : 'App is not allowed to access DND settings. To enable DND mode, give the app access to DND settings.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontFamily: 'PressStart2P',
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 20),
              if (!dndController.notifPolicyAccess)
                buildRetroButton(
                  'Open Notification Policy Access Settings',
                  getShade(userColor, 300),
                  () async {
                    await dndController.openNotificationPolicyAccessSettings();
                  },
                ),
              if (dndController.notifPolicyAccess)
                buildRetroButton(
                  'Toggle DND mode',
                  getShade(userColor, 300),
                  () async {
                    await dndController.toggleDnd();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
