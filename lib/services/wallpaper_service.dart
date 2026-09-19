import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wallora/utils/relaunch_guard.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';
import 'package:gal/gal.dart';

/// Where the wallpaper should be applied. Only meaningful on Android —
/// iOS has no equivalent API, so this is ignored there (see [apply]).
enum WallpaperTarget { home, lock, both }

/// Wraps the platform difference we discovered earlier: Android can set
/// wallpaper directly via WallpaperManager; iOS has no public API for
/// that, so the best we can do is save the image to Photos and let the
/// user set it manually from Settings.
///
/// This is the "adapter" pattern — the rest of the app calls one method,
/// `apply()`, and never needs an `if (Platform.isAndroid)` check anywhere
/// else in the codebase.
class WallpaperService {
  final _manager = WallpaperManagerFlutter();

  /// Downloads [imageUrl] (via the shared disk cache, so a wallpaper the
  /// user already viewed in the grid doesn't get re-downloaded) and applies
  /// it as requested. Returns a user-facing success message.
  ///
  /// Throws a plain [Exception] with a readable message on failure —
  /// the UI layer decides how to display it (we use a SnackBar).
  Future<String> apply(String imageUrl, WallpaperTarget target) async {
    if (imageUrl.isEmpty) {
      throw Exception('This wallpaper has no full-size image available.');
    }

    final file = await DefaultCacheManager().getSingleFile(imageUrl);

    if (Platform.isAndroid) {
      final location = switch (target) {
        WallpaperTarget.home => WallpaperManagerFlutter.homeScreen,
        WallpaperTarget.lock => WallpaperManagerFlutter.lockScreen,
        WallpaperTarget.both => WallpaperManagerFlutter.bothScreens,
      };
      if (target != WallpaperTarget.lock) {
        await RelaunchGuard.arm();
      }
      final ok = await _manager.setWallpaper(file, location);
      if (!ok) {
        throw Exception('The system declined to set the wallpaper.');
      }
      return 'Wallpaper applied.';
    }

    if (Platform.isIOS) {
      // iOS has no public wallpaper-setting API — this is an OS restriction,
      // not a limitation of this package. Saving to Photos + a short
      // instruction is the standard workaround every wallpaper app on the
      // App Store uses.
      await Gal.putImage(file.path);
      return 'Saved to Photos. Set it from Settings > Wallpaper.';
    }

    throw UnsupportedError(
      'Wallpaper setting is not supported on this platform.',
    );
  }
}
