// home_screen.dart — FIRST DRAFT, throwaway, replaced in step 7.
// The only goal: prove data flows all the way from Pexels to the screen.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallpapers')),
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, _) {
          if (provider.state == ViewState.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          // Plain ListView of text — no images, no grid, no styling.
          // If real photographer names scroll on screen, the ENTIRE
          // chain works: API key -> HTTP -> JSON -> model -> provider
          // -> notifyListeners -> Consumer rebuild.
          return ListView.builder(
            itemCount: provider.wallpapers.length,
            itemBuilder: (context, i) => ListTile(
              title: Text(provider.wallpapers[i].photographer),
            ),
          );
        },
      ),
    );
  }
}
