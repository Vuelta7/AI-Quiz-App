import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learn_n/A%20start%20page/splash_screen.dart';
import 'package:learn_n/firebase_options.dart';
import 'package:learn_n/notification.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      home: SplashScreen(),
    );
  }
}
// Platform  Firebase App Id
// web       1:1031285993587:web:3ad51e4e6c175372133a06
// android   1:1031285993587:android:f7d84d73551d5de6133a06
// ios       1:1031285993587:ios:1e0b9df9f80d8983133a06

// badge sound

//task
//add sound effect 
//add more correct message
//headercolor
//add content in the drawer
//add background look like a paper
//dark mode/light mode alongside search bar
//add drag and drop folder
//fix text in flashcard if it overlapped
//notifcation
