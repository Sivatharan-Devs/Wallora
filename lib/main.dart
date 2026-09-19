import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'providers/wallpaper_provider.dart';
import 'services/api_service.dart';
import 'services/onboarding_service.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'utils/relaunch_guard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');
  // SharedPreferences.getInstance() is async, same reason dotenv.load is
  // awaited above — both must finish before the widget tree that depends
  // on them is built.
  final prefs = await SharedPreferences.getInstance();

  // True only when the app is restarting right after a wallpaper change.
  final skipSplash = await RelaunchGuard.consume();

  runApp(
    MyApp(
      onboardingService: OnboardingService(prefs),
      skipSplash: skipSplash,
    ),
  );
}

class MyApp extends StatelessWidget {
  final OnboardingService onboardingService;
  final bool skipSplash;

  const MyApp({
    super.key,
    required this.onboardingService,
    this.skipSplash = false,
  });

  @override
  Widget build(BuildContext context) {
    // MultiProvider, now that we have two different kinds of things to
    // provide down the tree:
    //  - Provider.value for OnboardingService: a plain object, not a
    //    ChangeNotifier. Nothing about it changes over time in a way the
    //    UI needs to react to, so there's no notifyListeners() to wire up —
    //    it's here purely so any screen can reach it via context.read()
    //    without main.dart having to pass it through every constructor.
    //  - ChangeNotifierProvider for WallpaperProvider: state that DOES
    //    change and DOES need widgets to rebuild in response.
    return MultiProvider(
      providers: [
        Provider<OnboardingService>.value(value: onboardingService),
        ChangeNotifierProvider(
          create: (_) => WallpaperProvider(
            apiService: ApiService(apiKey: dotenv.env['PEXELS_API_KEY'] ?? ''),
          )..loadInitial(),
        ),
      ],
      child: MaterialApp(
        title: 'Wallora',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          useMaterial3: true,
        ),
        home: skipSplash && onboardingService.hasSeenOnboarding
            ? const HomeScreen()
            : const SplashScreen(),
      ),
    );
  }
}
