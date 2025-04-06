import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:go_router/go_router.dart';
import 'package:learn_n/core/provider/dnd_provider.dart';
import 'package:learn_n/core/provider/user_color_provider.dart';
import 'package:learn_n/core/utils/themes.dart';
import 'package:learn_n/features/auth/page/login_page.dart';
import 'package:learn_n/features/auth/page/register_page.dart';
import 'package:learn_n/features/auth/widgets/forgot_account.dart';
import 'package:learn_n/features/home/home_main.dart';
import 'package:learn_n/features/introduction/page/liquid_swipe.dart';
import 'package:learn_n/features/introduction/page/splash_page.dart';
import 'package:learn_n/features/introduction/page/start_page.dart';
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
  // debugPaintSizeEnabled = true;
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final GoRouter _router = GoRouter(
  routerNeglect: true,
  initialLocation: '/',
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
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/forgot-account',
      builder: (context, state) => const ForgotPassword(),
    ),
  ],
);

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Future.microtask(() => ref.read(dndProvider));
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final dndController = ref.read(dndProvider);
    if (state == AppLifecycleState.resumed) {
      dndController.toggleDnd();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      dndController.toggleDnd();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Learn-N',
      theme: buildLearnNThemes(
          ref.watch(textIconColorProvider), ref.watch(userColorProvider)),
      routerConfig: _router,
    );
  }
}

// Platform  Firebase App Id
// web       1:1031285993587:web:3ad51e4e6c175372133a06
// android   1:1031285993587:android:f7d84d73551d5de6133a06
// ios       1:1031285993587:ios:1e0b9df9f80d8983133a06
