import 'dart:async';

/// Service for monitoring network connectivity status.
abstract class ConnectivityService {
  /// Stream of connectivity status changes.
  Stream<bool> get connectivityStream;

  /// Returns true if currently online.
  Future<bool> get isOnline;

  /// Checks current connectivity status.
  Future<bool> checkConnectivity();
}

/// Represents the current connectivity status.
class ConnectivityStatus {
  final bool isOnline;
  final DateTime lastChecked;

  const ConnectivityStatus({
    this.isOnline = true,
    required this.lastChecked,
  });
}

/// Mock implementation of ConnectivityService for development and testing.
///
/// Later this will wrap connectivity_plus package.
class MockConnectivityService implements ConnectivityService {
  final _controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get connectivityStream => _controller.stream;

  @override
  Future<bool> get isOnline async => true;

  @override
  Future<bool> checkConnectivity() async => true;
}