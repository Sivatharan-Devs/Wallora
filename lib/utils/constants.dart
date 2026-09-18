/// Central place for values that would otherwise be "magic strings/numbers"
/// scattered through the codebase. If Pexels changes their page size limit,
/// you change one line here — not every file that happens to fetch a page.
class ApiConstants {
  ApiConstants._(); // prevents accidental instantiation — this is a namespace, not an object

  static const String baseUrl = 'https://api.pexels.com/v1';
  static const int perPage = 30;
  static const Duration requestTimeout = Duration(seconds: 15);
}
