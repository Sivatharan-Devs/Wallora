import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/onboarding_service.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';

/// Shown briefly on every app launch. Its only responsibility is
/// deciding which screen comes next — it holds no wallpaper data and
/// doesn't touch WallpaperProvider at all.
///
/// One orchestrated intro plays on launch:
///   1. the gradient slowly settles into its final angle,
///   2. the logo fades in and scales up with a soft overshoot,
///   3. the app name fades in and slides up just after,
/// then the screen cross-fades into the next one.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _introDuration = Duration(milliseconds: 1600);
  static const _holdDuration = Duration(milliseconds: 500);
  static const _exitDuration = Duration(milliseconds: 600);

  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _textFade;
  late final Animation<Offset> _textSlide;
  late final Animation<Alignment> _gradientBegin;
  late final Animation<Alignment> _gradientEnd;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(vsync: this, duration: _introDuration);

    // Logo: 0% -> 55% of the timeline.
    _logoFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
    );
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
      ),
    );

    // Title: starts once the logo is mostly in, finishes at 90%.
    _textFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.4, 0.9, curve: Curves.easeOut),
    );
    _textSlide =
        Tween<Offset>(
          begin: const Offset(0, 0.4),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic),
          ),
        );

    // Background: the gradient angle drifts into your original
    // bottomLeft -> topRight direction over the whole intro.
    final drift = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _gradientBegin = AlignmentTween(
      begin: Alignment.bottomCenter,
      end: Alignment.bottomLeft,
    ).animate(drift);
    _gradientEnd = AlignmentTween(
      begin: Alignment.topCenter,
      end: Alignment.topRight,
    ).animate(drift);

    _decideNextScreen();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _decideNextScreen() async {
    // Respect the system "reduce motion" setting: jump to the end state.
    // (MediaQuery isn't safe to read in initState, so wait one frame.)
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;

    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.value = 1.0;
    } else {
      await _controller.forward();
    }
    if (!mounted) return;

    // Let the finished logo sit for a beat before leaving.
    await Future.delayed(_holdDuration);
    if (!mounted) return;

    final hasSeenOnboarding = context
        .read<OnboardingService>()
        .hasSeenOnboarding;

    final Widget next = hasSeenOnboarding
        ? const HomeScreen()
        : const OnboardingScreen();

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: _exitDuration,
        pageBuilder: (_, _, _) => next,
        transitionsBuilder: (_, animation, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        // `child` is built once; only the gradient is rebuilt per frame.
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FadeTransition(
                opacity: _logoFade,
                child: ScaleTransition(
                  scale: _logoScale,
                  child: Image.asset(
                    'assets/images/logo_.png',
                    width: 200,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              FadeTransition(
                opacity: _textFade,
                child: SlideTransition(
                  position: _textSlide,
                  child: const Text(
                    'Wallora',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: _gradientBegin.value,
                end: _gradientEnd.value,
                colors: const [
                  Color(0xff3345FD), // blue
                  Color(0xff7826FC), // violet
                  Color(0xffC402D2), // magenta
                  Color(0xffFC1E97), // pink
                  Color(0xffFC543C), // red-orange
                  Color(0xffFE8419), // orange
                ],
                stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
              ),
            ),
            child: child,
          );
        },
      ),
    );
  }
}
