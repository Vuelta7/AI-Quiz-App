import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/components/firebase_options.dart';
import 'package:learn_n/components/my_app.dart';
import 'package:learn_n/home%20page/notes%20page/notification_init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

//Mighty Creation of Uriel
// TODO:
// add a notification permission handler
// UX redesign
// enhance the UX of the Answering experience
// points to change the UI color
// text regocnition
