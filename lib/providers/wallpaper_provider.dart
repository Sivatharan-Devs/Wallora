import 'package:flutter/foundation.dart';

import '../models/wallpaper_model.dart';
import '../services/api_service.dart';

/// Every screen state the UI can be in, named explicitly instead of
/// juggling separate booleans like `isLoading`, `hasError`, `isEmpty`.
/// With booleans you can accidentally end up with isLoading == true AND
/// hasError == true at the same time — an impossible state the UI still
/// has to handle. An enum makes impossible states actually impossible.
enum ViewState { idle, loading, loadingMore, error }

/// Holds all state related to browsing wallpapers, and is the ONLY class
/// in the app that talks to [ApiService]. Screens never call ApiService
/// directly — they call this provider, which calls the service, which
/// calls the network. Each layer only knows about the one below it.
///
/// Extends ChangeNotifier: Flutter's built-in "observable" base class.
/// Calling notifyListeners() tells every widget currently listening
/// (via Consumer/context.watch, see the screens) to rebuild.
class WallpaperProvider extends ChangeNotifier {
  final ApiService _apiService;

  WallpaperProvider({required ApiService apiService})
    : _apiService = apiService;

  // --- Private mutable state ---
  final List<WallpaperModel> _wallpapers = [];
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  int _page = 1;
  bool _hasMore = true;

  // --- Public read-only getters ---
  // We never expose _wallpapers directly — List.unmodifiable() means a
  // widget holding a reference to this list can't accidentally (or
  // maliciously) call .add() on it and corrupt state outside notifyListeners.
  List<WallpaperModel> get wallpapers => List.unmodifiable(_wallpapers);
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  /// Called once when the app starts (see main.dart). Fetches page 1.
  Future<void> loadInitial() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners(); // UI immediately shows a spinner

    try {
      final results = await _apiService.fetchCurated(page: 1);
      _wallpapers
        ..clear()
        ..addAll(results);
      _page = 1;
      _hasMore = results.isNotEmpty;
      _state = ViewState.idle;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    }

    notifyListeners(); // UI shows either the grid or the error view
  }

  /// Called when the user scrolls near the bottom of the grid.
  /// Appends the next page instead of replacing the list.
  Future<void> loadMore() async {
    // Guard against firing five requests because the user scrolled fast,
    // and against requesting a page we already know doesn't exist.
    if (_state == ViewState.loadingMore || !_hasMore) return;

    _state = ViewState.loadingMore;
    notifyListeners();

    final nextPage = _page + 1;
    try {
      final results = await _apiService.fetchCurated(page: nextPage);
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _wallpapers.addAll(results);
        _page = nextPage;
      }
      _state = ViewState.idle;
    } on ApiException catch (e) {
      // Deliberately NOT ViewState.error here — the grid the user is
      // already looking at is still valid. We only want to surface this
      // as a transient message, not blow away the whole screen.
      _errorMessage = e.message;
      _state = ViewState.idle;
    }

    notifyListeners();
  }

  /// Called by the UI after it has shown [errorMessage] once (e.g. in a
  /// SnackBar), so the same message doesn't reappear on the next rebuild.
  /// No notifyListeners() here on purpose — nothing visual depends on
  /// errorMessage being null, so there's nothing that needs to rebuild.
  void clearError() {
    _errorMessage = null;
  }
}
