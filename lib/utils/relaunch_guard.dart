import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// On Android 12+, changing the *home* wallpaper makes the system refresh
/// its dynamic colors, which can recreate your activity. Flutter then
/// restarts from main() and lands on SplashScreen again.
///
/// This guard remembers "we just set a wallpaper" across that restart so
/// main() can skip the splash.
class RelaunchGuard {
  RelaunchGuard._();

  static const _key = 'wallpaper_change_at';
  static const _window = Duration(seconds: 20);

  /// Call right BEFORE you apply a wallpaper.
  // for debugPrint

  static Future<void> arm() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, DateTime.now().millisecondsSinceEpoch);
    debugPrint('RelaunchGuard: armed');
  }

  static Future<bool> consume() async {
    final prefs = await SharedPreferences.getInstance();
    final armedAt = prefs.getInt(_key);
    if (armedAt == null) return false;

    final age = DateTime.now().millisecondsSinceEpoch - armedAt;
    return age <= _window.inMilliseconds;
  }
}
