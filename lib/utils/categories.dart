/// Pexels doesn't expose a real "category" concept — under the hood,
/// tapping a category just runs a search using that word as the query.
/// Keeping the list here (not hardcoded into a widget) means adding or
/// renaming a category is a one-line change, and it's easy to test the
/// list itself without touching any UI.
class WallpaperCategories {
  WallpaperCategories._();

  static const List<String> all = [
    'Nature',
    'Abstract',
    'Minimal',
    'Dark',
    'Space',
    'City',
    'Ocean',
    'Animals',
    'Flowers',
    'Technology',
  ];
}
