import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/wallpaper_model.dart';

/// One tile in the grid. Stateless — it has no state of its own, it just
/// renders whatever [wallpaper] it's given and reports taps upward via
/// [onTap]. This is a deliberate pattern: this widget doesn't know or
/// care about Navigator, routes, or what happens after the tap — that's
/// the parent screen's job. Keeps this widget reusable and easy to test.
class WallpaperGridItem extends StatelessWidget {
  final WallpaperModel wallpaper;
  final VoidCallback onTap;

  const WallpaperGridItem({
    super.key,
    required this.wallpaper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: CachedNetworkImage(
        imageUrl: wallpaper.thumbnailUrl,
        fit: BoxFit.cover,
        // Shown instantly while the image downloads/loads from cache —
        // avoids the blank-flash the original Image.network had.
        placeholder: (context, url) => Container(color: Colors.grey.shade900),
        // Shown if the URL is broken or the request fails — the original
        // code had no fallback here at all, so a bad URL just left a gap.
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade900,
          child: const Icon(Icons.broken_image_outlined, color: Colors.white24),
        ),
      ),
    );
  }
}
