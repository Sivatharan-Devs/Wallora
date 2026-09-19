import 'package:shared_preferences/shared_preferences.dart';

/// Wraps SharedPreferences so nothing else in the app needs to know the
/// storage key string or that SharedPreferences is even the mechanism
/// used. If we later swap this for secure storage or a backend flag,
/// only this file changes.
class OnboardingService {
  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  final SharedPreferences _prefs;

  const OnboardingService(this._prefs);

  bool get hasSeenOnboarding => _prefs.getBool(_hasSeenOnboardingKey) ?? false;

  Future<void> setSeenOnboarding() =>
      _prefs.setBool(_hasSeenOnboardingKey, true);
}
