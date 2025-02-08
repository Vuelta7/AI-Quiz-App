import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/components/firebase_options.dart';
import 'package:learn_n/components/my_app.dart';
import 'package:learn_n/home%20page/notification%20page/notification_body.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  await NotificationService.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    const MyApp(),
  );
}

// Platform  Firebase App Id
// web       1:1031285993587:web:3ad51e4e6c175372133a06
// android   1:1031285993587:android:f7d84d73551d5de6133a06
// ios       1:1031285993587:ios:1e0b9df9f80d8983133a06

// Mighty Creation of Uriel
// TODO:
// enhance the UX of the Answering experience
// add a notification handler for the notification page
// add a privacy policy terms and conditions page
// create the dnd mechanics
// introduction page
// Not important:
// WebPage fix
// add automatic qna
