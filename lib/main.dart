import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/firebase_options.dart';
import 'package:learn_n/start%20page/splash_screen_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      home: SplashScreenWidget(),
    );
  }
}

// Platform  Firebase App Id
// web       1:896261439291:web:23c4d2950fa1109065811e 
// android   1:896261439291:android:012379d62b69521f65811e
// ios       1:896261439291:ios:405647bf4574925d65811e
