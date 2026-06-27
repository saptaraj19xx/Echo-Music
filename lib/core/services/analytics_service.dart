/// Service for tracking analytics events and screen views.
abstract class AnalyticsService {
  /// Logs a screen view event.
  Future<void> logScreen(String screenName);

  /// Logs a custom event with optional parameters.
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters);

}

/// Mock implementation of AnalyticsService for development and testing.
class MockAnalyticsService implements AnalyticsService {
  @override
  Future<void> logScreen(String screenName) async {
    // Mock: no-op (replace with Firebase Analytics later).
  }

  @override
  Future<void> logEvent(String eventName, Map<String, dynamic>? parameters) async {
    // Mock: no-op (replace with Firebase Analytics later).
  }
}