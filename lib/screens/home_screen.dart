import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/state_views.dart';
import 'full_screen_view.dart';

/// StatefulWidget (not Stateless) for one reason: we need initState()
/// to attach a listener that watches for transient "load more" errors
/// and shows them as a SnackBar. Everything else here could have been
/// stateless — the actual wallpaper data all lives in WallpaperProvider,
/// not in this widget's own state.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // context.read (not context.watch) because we're not inside build() —
    // we just want a one-time reference to call addListener on.
    final provider = context.read<WallpaperProvider>();
    provider.addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    final provider = context.read<WallpaperProvider>();
    // Only act if there's a pending message AND we still have wallpapers
    // on screen (an initial-load error is handled by ErrorView instead).
    if (provider.errorMessage != null && provider.wallpapers.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      provider.clearError();
    }
  }

  @override
  void dispose() {
    // Always remove listeners you add — a provider outliving this screen
    // would otherwise keep calling a callback tied to a dead widget.
    context.read<WallpaperProvider>().removeListener(_onProviderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallpapers')),
      // Consumer rebuilds ONLY this subtree when WallpaperProvider calls
      // notifyListeners() — the AppBar above doesn't need to rebuild every
      // time a new page of wallpapers loads, so it's kept outside.
      body: Consumer<WallpaperProvider>(
        builder: (context, provider, _) {
          if (provider.state == ViewState.loading) {
            return const LoadingView();
          }

          if (provider.state == ViewState.error &&
              provider.wallpapers.isEmpty) {
            return ErrorView(
              message: provider.errorMessage ?? 'Something went wrong.',
              onRetry: provider.loadInitial,
            );
          }

          return NotificationListener<ScrollNotification>(
            // Infinite scroll: request the next page once the user is
            // within 300px of the bottom, instead of the original app's
            // separate "Load More" button. This is a UX upgrade we're
            // layering on now that pagination logic lives in the provider
            // and is trivial to trigger from anywhere.
            onNotification: (notification) {
              final metrics = notification.metrics;
              if (metrics.pixels >= metrics.maxScrollExtent - 300) {
                provider.loadMore();
              }
              return false; // allow the notification to keep bubbling
            },
            child: ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                overscroll: false,
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(2),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                  childAspectRatio: 2 / 3,
                ),
                itemCount: provider.wallpapers.length,
                itemBuilder: (context, index) {
                  final wallpaper = provider.wallpapers[index];
                  return WallpaperGridItem(
                    key: ValueKey(wallpaper.id), // stable identity per item
                    wallpaper: wallpaper,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => FullScreenView(wallpaper: wallpaper),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
