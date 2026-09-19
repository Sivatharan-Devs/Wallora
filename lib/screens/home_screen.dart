import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';
import '../widgets/wallpaper_grid_item.dart';
import '../widgets/state_views.dart';
import '../widgets/wallpaper_search_bar.dart';
import '../widgets/category_list.dart';
import 'full_screen_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<WallpaperProvider>().addListener(_onProviderChanged);
  }

  void _onProviderChanged() {
    final provider = context.read<WallpaperProvider>();
    if (provider.errorMessage != null && provider.wallpapers.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      provider.clearError();
    }
  }

  @override
  void dispose() {
    context.read<WallpaperProvider>().removeListener(_onProviderChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('Wallora')),
      body: SafeArea(
        child: Column(
          children: [
            // Persistent controls — stay visible and usable no matter what
            // state the grid below is in (loading, error, or showing results).
            const WallpaperSearchBar(),
            const CategoryList(),
            const SizedBox(height: 4),
            Expanded(
              child: Consumer<WallpaperProvider>(
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

                  if (provider.wallpapers.isEmpty) {
                    // Zero results for a search/category, as opposed to an
                    // error — a distinct, calmer state than ErrorView.
                    return const Center(
                      child: Text(
                        'No wallpapers found. Try a different search.',
                      ),
                    );
                  }

                  return NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      final metrics = notification.metrics;
                      if (metrics.pixels >= metrics.maxScrollExtent - 300) {
                        provider.loadMore();
                      }
                      return false;
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.all(2),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 2,
                            mainAxisSpacing: 2,
                            childAspectRatio: 2 / 3,
                          ),
                      itemCount: provider.wallpapers.length,
                      itemBuilder: (context, index) {
                        final wallpaper = provider.wallpapers[index];
                        return WallpaperGridItem(
                          key: ValueKey(wallpaper.id),
                          wallpaper: wallpaper,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  FullScreenView(wallpaper: wallpaper),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
