import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/utils/themes.dart';
import 'package:learn_n/features/auth/view/page/auth_page.dart';
import 'package:learn_n/features/home/home_main.dart';
import 'package:learn_n/features/introduction/liquid_swipe.dart';
import 'package:learn_n/features/introduction/splash_page.dart';
import 'package:learn_n/features/introduction/start_page.dart';
import 'package:learn_n/features/web/web_main.dart';
import 'package:learn_n/services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  usePathUrlStrategy();
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

final GoRouter _router = GoRouter(
  routerNeglect: true,
  initialLocation: '/',
  redirect: (context, state) {
    return null;
  },
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/web',
      builder: (context, state) => const WebMain(),
    ),
    GoRoute(
      path: '/start',
      builder: (context, state) => const StartPage(),
    ),
    GoRoute(
      path: '/intro',
      builder: (context, state) => const LiquidSwipeIntro(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeMain(),
    ),
    GoRoute(
      path: '/auth/:isLogin',
      builder: (context, state) {
        final isLogin = state.pathParameters['isLogin'] == 'true';
        return AuthScreen(isLogin: isLogin);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      theme: learnNThemes,
      routerConfig: _router,
    );
  }
}

// Platform  Firebase App Id
// web       1:1031285993587:web:3ad51e4e6c175372133a06
// android   1:1031285993587:android:f7d84d73551d5de6133a06
// ios       1:1031285993587:ios:1e0b9df9f80d8983133a06

// Mighty Creation of Uriel
// TODO:
// WebPage fix
// create the dnd mechanics
// make conditions and info how to update streakpet
// add providers
// add forgot password(to know if the user really forgot the password ask about petname, points, hints)
