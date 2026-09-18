/// Represents a single wallpaper, parsed from the Pexels API response.
///
/// Why a class instead of passing `Map<String, dynamic>` around:
/// - The compiler catches typos in field names at build time, not runtime.
/// - `fromJson` is the ONE place that knows about Pexels' JSON shape — if
///   the API changes, or we switch providers, only this file changes.
/// - Every field is `final`: once built, a WallpaperModel can't be mutated
///   by accident somewhere deep in the widget tree.
class WallpaperModel {
  final int id;
  final String thumbnailUrl;
  final String fullUrl;
  final String photographer;
  final int width;
  final int height;

  const WallpaperModel({
    required this.id,
    required this.thumbnailUrl,
    required this.fullUrl,
    required this.photographer,
    required this.width,
    required this.height,
  });

  /// Builds a model from one entry of Pexels' `photos` array.
  ///
  /// We defensively cast and fall back on missing fields (`?? 'Unknown'`)
  /// rather than letting a single malformed entry crash the whole grid —
  /// the original code assumed the response always matches expectations,
  /// which is exactly the kind of assumption real APIs violate eventually.
  factory WallpaperModel.fromJson(Map<String, dynamic> json) {
    final src = json['src'] as Map<String, dynamic>? ?? const {};
    return WallpaperModel(
      id: json['id'] as int? ?? 0,
      thumbnailUrl: src['tiny'] as String? ?? '',
      fullUrl: src['large2x'] as String? ?? src['original'] as String? ?? '',
      photographer: json['photographer'] as String? ?? 'Unknown',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }
}
