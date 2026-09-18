import 'package:wallora/services/api_service.dart';

// Standalone smoke test — NOT a Flutter widget test, just plain Dart.
// Run with: dart run tool/smoke_test.dart
//
// Purpose: prove the networking + parsing layer works BEFORE writing
// a single widget. If this fails, the bug is in api_service.dart or
// wallpaper_model.dart — nowhere else. If it passes, everything above
// this layer can be trusted to receive real, correctly-shaped data.

Future<void> main() async {
  // Paste a real key here temporarily to run this — never commit it.
  const testApiKey = 'YOUR_PEXELS_API_KEY';

  final api = ApiService(apiKey: testApiKey);

  try {
    final wallpapers = await api.fetchCurated(page: 1);
    print('Success: fetched ${wallpapers.length} wallpapers.');
    if (wallpapers.isNotEmpty) {
      final first = wallpapers.first;
      print(
        'First result -> id: ${first.id}, photographer: ${first.photographer}',
      );
      print('Thumbnail URL: ${first.thumbnailUrl}');
    }
  } on ApiException catch (e) {
    print(
      'ApiException (this is the point of the test — it should be readable): $e',
    );
  }
}
