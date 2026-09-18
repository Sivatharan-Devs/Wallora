import 'dart:io';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/wallpaper_model.dart';
import '../services/wallpaper_service.dart';

class FullScreenView extends StatefulWidget {
  final WallpaperModel wallpaper;

  const FullScreenView({super.key, required this.wallpaper});

  @override
  State<FullScreenView> createState() => _FullScreenViewState();
}

class _FullScreenViewState extends State<FullScreenView> {
  // A plain service instance, not something injected via Provider.
  // WallpaperService has no state of its own and isn't shared across
  // screens, so there's no benefit to making it a singleton via Provider —
  // that would just add indirection for nothing.
  final _wallpaperService = WallpaperService();
  bool _applying = false;

  Future<void> _apply(WallpaperTarget target) async {
    setState(() => _applying = true);
    try {
      final message = await _wallpaperService.apply(
        widget.wallpaper.fullUrl,
        target,
      );
      if (!mounted) {
        return; // guard: the user may have navigated away mid-request
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _applying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Expanded(
            child: CachedNetworkImage(
              imageUrl: widget.wallpaper.fullUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _applying
                  ? const Center(child: CircularProgressIndicator())
                  : _buildActions(),
            ),
          ),
        ],
      ),
    );
  }

  /// iOS has no concept of "home vs lock screen" for third-party apps —
  /// it's all just "save to Photos" — so showing three buttons there
  /// would offer a choice that doesn't actually do anything different.
  /// This is the platform-adaptive-UI technique: branch on Platform at
  /// the presentation layer, not just in the service.
  Widget _buildActions() {
    if (Platform.isIOS) {
      return Center(
        child: FilledButton.icon(
          onPressed: () =>
              _apply(WallpaperTarget.home), // target is ignored on iOS
          icon: const Icon(Icons.download),
          label: const Text('Save to Photos'),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: () => _apply(WallpaperTarget.home),
          child: const Text('Home screen'),
        ),
        TextButton(
          onPressed: () => _apply(WallpaperTarget.lock),
          child: const Text('Lock screen'),
        ),
        TextButton(
          onPressed: () => _apply(WallpaperTarget.both),
          child: const Text('Both'),
        ),
      ],
    );
  }
}
