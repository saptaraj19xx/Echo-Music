/// Service for managing local notifications.
abstract class NotificationService {
  /// Initializes the notification service.
  Future<void> initialize();

  /// Shows a notification with the given details.
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Cancels a notification by id.
  Future<void> cancelNotification(int id);

  /// Cancels all notifications.
  Future<void> cancelAllNotifications();
}

/// Mock implementation of NotificationService for development and testing.
///
/// Later this will use flutter_local_notifications package.
class MockNotificationService implements NotificationService {
  @override
  Future<void> initialize() async {
    // Mock: no-op.
  }

  @override
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Mock: no-op.
  }

  @override
  Future<void> cancelNotification(int id) async {
    // Mock: no-op.
  }

  @override
  Future<void> cancelAllNotifications() async {
    // Mock: no-op.
  }
}