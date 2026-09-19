import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/wallpaper_provider.dart';

/// A StatefulWidget only because it owns a TextEditingController, which
/// must be created once and disposed — it has no wallpaper data itself.
/// Every keystroke is forwarded to WallpaperProvider.onSearchChanged(),
/// which owns the actual debouncing and fetching logic. This widget
/// doesn't know or care that a 500ms debounce exists.
class WallpaperSearchBar extends StatefulWidget {
  const WallpaperSearchBar({super.key});

  @override
  State<WallpaperSearchBar> createState() => _WallpaperSearchBarState();
}

class _WallpaperSearchBarState extends State<WallpaperSearchBar> {
  final _controller = TextEditingController();

  void _onChanged(String text) {
    setState(() {}); // rebuild just to show/hide the clear (X) button
    context.read<WallpaperProvider>().onSearchChanged(text);
  }

  void _clear() {
    _controller.clear();
    _onChanged('');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Search wallpapers...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(icon: const Icon(Icons.close), onPressed: _clear),
          filled: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
