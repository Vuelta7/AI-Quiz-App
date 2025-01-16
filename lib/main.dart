import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/B%20home%20page/notification_body.dart';
import 'package:learn_n/firebase_options.dart';
import 'package:learn_n/my_app.dart';

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
//fix
// Register and Login fix (After Registration automatically goes in Home Page)
// Fullscreen for DnD and stopping students from distraction (Can manually turn off and on)
// Notification Timer fix (Fix The Notification Text reseting when changing page)
// UX redesign
// enhance the UX of the Answering experience 
// limited hints(half of the word, if theres a multiple word half of every word)
// Leader boards based on score
// points to change the UI color
// points to change the background music