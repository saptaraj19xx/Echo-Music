import 'dart:async';

/// Service for exposing connectivity status.
///
/// Purpose:
/// - Provide a lightweight connectivity API to the rest of the app.
///
/// Future production implementation:
/// - Replace [MockConnectivityService] with an implementation that wraps
///   `connectivity_plus`.
///
/// Current mock limitations:
/// - The mock can only represent a static/controllable connectivity state.
/// - No real device/network probing is performed.
abstract class ConnectivityService {
  /// True when the app should treat the device as online.
  bool get isOnline;

  /// True when the app should treat the device as offline.
  bool get isOffline;

  /// Stream of connectivity changes.
  ///
  /// Emits `true` for online, `false` for offline.
  Stream<bool> get connectivityStream;
}

