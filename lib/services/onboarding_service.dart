import 'package:shared_preferences/shared_preferences.dart';

class OnboardingService {
  static const String _keyHasSeenOnboarding = 'has_seen_onboarding';

  /// Check if the user has already completed or skipped the onboarding tour.
  static Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasSeenOnboarding) ?? false;
  }

  /// Mark onboarding as completed.
  static Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, true);
  }

  /// Reset onboarding state to allow re-triggering the tour.
  static Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasSeenOnboarding, false);
  }
}
