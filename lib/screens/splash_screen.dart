import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/onboarding_service.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Shown briefly on every app launch. Its only responsibility is
/// deciding which screen comes next — it holds no wallpaper data and
/// doesn't touch WallpaperProvider at all.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _decideNextScreen();
  }

  Future<void> _decideNextScreen() async {
    // A short minimum delay so the splash doesn't just flash by on a
    // fast device — purely a UX choice, not a technical requirement.
    // (Reading the onboarding flag itself is effectively instant.)
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final hasSeenOnboarding = context
        .read<OnboardingService>()
        .hasSeenOnboarding;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            hasSeenOnboarding ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wallpaper_rounded, size: 72, color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Wallora',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
