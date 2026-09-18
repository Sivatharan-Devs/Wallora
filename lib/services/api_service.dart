import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../models/wallpaper_model.dart';
import '../utils/constants.dart';

/// A typed exception carrying a message that's safe to show a user directly.
/// We never surface raw exceptions (like SocketException) to the UI layer —
/// the UI shouldn't need to know or care what http package we're using.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// Everything that talks to the Pexels API lives here, and nowhere else.
/// The provider layer calls this; the UI layer never sees `http` or `json`.
///
/// The API key is injected via the constructor rather than read from
/// dotenv inside this class. That's "dependency injection" — it means
/// ApiService doesn't need to know HOW the key was obtained, which makes
/// it trivial to test with a fake key and no real network calls.
class ApiService {
  final http.Client _client;
  final String _apiKey;

  ApiService({required String apiKey, http.Client? client})
    : _apiKey = apiKey,
      _client = client ?? http.Client();

  Future<List<WallpaperModel>> fetchCurated({required int page}) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/curated?per_page=${ApiConstants.perPage}&page=$page',
    );

    late http.Response response;
    try {
      response = await _client
          .get(uri, headers: {'Authorization': _apiKey})
          .timeout(ApiConstants.requestTimeout);
    } on SocketException {
      throw const ApiException(
        'No internet connection. Check your network and try again.',
      );
    } on http.ClientException {
      throw const ApiException('Could not reach the server. Please try again.');
    } catch (_) {
      // Catches timeouts and anything else unexpected — we'd rather show
      // a generic message than let a raw exception crash the widget tree.
      throw const ApiException('Something went wrong. Please try again.');
    }

    // Check status codes BEFORE trying to decode the body — jsonDecode()
    // on an error page's HTML (or an empty body) throws a confusing
    // FormatException instead of telling the user what actually happened.
    switch (response.statusCode) {
      case 200:
        break;
      case 401:
        throw const ApiException('Invalid API key. Check your .env file.');
      case 429:
        throw const ApiException('Too many requests — please wait a moment.');
      default:
        throw ApiException(
          'Server error (${response.statusCode}). Please try again.',
        );
    }

    final Map<String, dynamic> body =
        jsonDecode(response.body) as Map<String, dynamic>;
    final List<dynamic> photos = body['photos'] as List<dynamic>? ?? const [];

    return photos
        .map((e) => WallpaperModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
