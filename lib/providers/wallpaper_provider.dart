import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/wallpaper_model.dart';
import '../services/api_service.dart';

enum ViewState { idle, loading, loadingMore, error }

/// Which endpoint the provider is currently pulling from. Not exposed
/// outside this file — the UI only needs to know about ViewState and
/// selectedCategory, not the internal fetch strategy.
enum _FetchMode { curated, search }

class WallpaperProvider extends ChangeNotifier {
  final ApiService _apiService;

  WallpaperProvider({required ApiService apiService})
    : _apiService = apiService;

  final List<WallpaperModel> _wallpapers = [];
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  int _page = 1;
  bool _hasMore = true;

  _FetchMode _mode = _FetchMode.curated;
  String? _activeQuery; // the term sent to /search; null when in curated mode
  String? _selectedCategory; // for UI highlighting only
  Timer? _debounce;

  List<WallpaperModel> get wallpapers => List.unmodifiable(_wallpapers);
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  String? get selectedCategory => _selectedCategory;

  /// Fetches whichever page is requested, from whichever endpoint is
  /// currently active. Every place that needs data — initial load,
  /// load-more, a fresh search — goes through this one method instead
  /// of each having its own copy of "if searching call X else call Y".
  Future<List<WallpaperModel>> _fetch(int page) {
    return _mode == _FetchMode.curated
        ? _apiService.fetchCurated(page: page)
        : _apiService.search(query: _activeQuery!, page: page);
  }

  /// Called once at app start (see main.dart).
  Future<void> loadInitial() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _fetch(1);
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

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_state == ViewState.loadingMore || !_hasMore) return;

    _state = ViewState.loadingMore;
    notifyListeners();

    final nextPage = _page + 1;
    try {
      final results = await _fetch(nextPage);
      if (results.isEmpty) {
        _hasMore = false;
      } else {
        _wallpapers.addAll(results);
        _page = nextPage;
      }
      _state = ViewState.idle;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.idle;
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
  }

  // --- Search ---

  /// Called on every keystroke from the search bar. Debounced: only the
  /// LAST call in a 500ms window actually triggers a network request.
  /// Cancelling the previous timer on every call is what makes this work —
  /// if the user keeps typing, the timer keeps getting reset and never fires
  /// until they pause.
  void onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      final trimmed = text.trim();
      if (trimmed.isEmpty) {
        _resetToCurated();
      } else {
        _selectedCategory = null; // typing overrides any selected category
        _runSearch(trimmed);
      }
    });
  }

  // --- Categories ---

  /// Tapping a category runs a search using the category name as the
  /// query. Tapping the SAME category again deselects it and returns to
  /// the curated feed — a common toggle pattern for filter chips.
  void selectCategory(String category) {
    _debounce
        ?.cancel(); // a category tap should win over a pending debounced search
    if (_selectedCategory == category) {
      _selectedCategory = null;
      _resetToCurated();
      return;
    }
    _selectedCategory = category;
    _runSearch(category);
  }

  Future<void> _resetToCurated() async {
    _mode = _FetchMode.curated;
    _activeQuery = null;
    _page = 1;
    _hasMore = true;
    await loadInitial();
  }

  Future<void> _runSearch(String query) async {
    _mode = _FetchMode.search;
    _activeQuery = query;
    _page = 1;
    _hasMore = true;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await _fetch(1);
      _wallpapers
        ..clear()
        ..addAll(results);
      _hasMore = results.isNotEmpty;
      _state = ViewState.idle;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _state = ViewState.error;
    }

    notifyListeners();
  }

  @override
  void dispose() {
    // A pending debounce timer holding a reference to a disposed provider
    // would fire into dead state later — always clean up Timers/Streams
    // in dispose().
    _debounce?.cancel();
    super.dispose();
  }
}
