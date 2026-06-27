import '../services/analytics_service.dart';

/// Firebase Analytics adapter.
///
/// Note: firebase_analytics dependency is not present in pubspec.yaml yet.
/// This adapter is intentionally stubbed for Sprint 12 foundation.
class AnalyticsAdapter implements AnalyticsService {
  AnalyticsAdapter();

  @override
  Future<void> logScreen(String screenName) async {
    // No-op until firebase_analytics is added in a later phase.
  }

  @override
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
    // No-op until firebase_analytics is added in a later phase.
  }
}



