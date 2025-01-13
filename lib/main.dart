import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:learn_n/A%20start%20page/splash_screen.dart';
import 'package:learn_n/B%20home%20page/notification_body.dart';
import 'package:learn_n/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();

  // Make the app fullscreen and hide system UI overlays
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      home: const SplashScreen(),
      theme: ThemeData(
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 60),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.all(27),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Colors.grey.shade300,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          selectionColor: Colors.red[100],
          selectionHandleColor: Colors.black,
          cursorColor: Colors.black,
        ),
      ),
    );
  }
}
// Platform  Firebase App Id
// web       1:1031285993587:web:3ad51e4e6c175372133a06
// android   1:1031285993587:android:f7d84d73551d5de6133a06
// ios       1:1031285993587:ios:1e0b9df9f80d8983133a06

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