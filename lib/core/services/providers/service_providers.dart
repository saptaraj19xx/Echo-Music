import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:echo/core/services/analytics_service.dart';
import 'package:echo/core/services/audio_service.dart';
import 'package:echo/core/services/cache_service.dart';
import 'package:echo/core/services/connectivity_service.dart';
import 'package:echo/core/services/download_service.dart';
import 'package:echo/core/services/notification_service.dart';
import 'package:echo/core/services/storage_service.dart';
import 'package:echo/core/services/share_service.dart';
import 'package:echo/core/services/settings_service.dart';

// ---------------------------------------------------------------------------
// Analytics Service Provider
// ---------------------------------------------------------------------------
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return MockAnalyticsService();
});

// ---------------------------------------------------------------------------
// Audio Service Provider
// ---------------------------------------------------------------------------
final audioServiceProvider = Provider<AudioService>((ref) {
  return MockAudioService();
});

// ---------------------------------------------------------------------------
// Cache Service Provider
// ---------------------------------------------------------------------------
final cacheServiceProvider = Provider<CacheService>((ref) {
  return MockCacheService();
});

// ---------------------------------------------------------------------------
// Connectivity Service Provider
// ---------------------------------------------------------------------------
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return MockConnectivityService();
});

// ---------------------------------------------------------------------------
// Download Service Provider
// ---------------------------------------------------------------------------
final downloadServiceProvider = Provider<DownloadService>((ref) {
  return MockDownloadService();
});

// ---------------------------------------------------------------------------
// Notification Service Provider
// ---------------------------------------------------------------------------
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return MockNotificationService();
});

// ---------------------------------------------------------------------------
// Storage Service Provider
// ---------------------------------------------------------------------------
final storageServiceProvider = Provider<StorageService>((ref) {
  return MockStorageService();
});

// ---------------------------------------------------------------------------
// Share Service Provider
// ---------------------------------------------------------------------------
final shareServiceProvider = Provider<ShareService>((ref) {
  return MockShareService();
});

// ---------------------------------------------------------------------------
// Settings Service Provider
// ---------------------------------------------------------------------------
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return MockSettingsService();
});