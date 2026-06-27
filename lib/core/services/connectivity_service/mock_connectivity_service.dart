import 'dart:async';

import 'service.dart';

/// Mock implementation of [ConnectivityService].
///
/// Current mock limitations:
/// - Always defaults to online.
/// - Provides no automatic detection; use only for wiring and tests.
class MockConnectivityService implements ConnectivityService {
  final _controller = StreamController<bool>.broadcast();

  bool _isOnline = true;

  @override
  bool get isOnline => _isOnline;

  @override
  bool get isOffline => !_isOnline;

  @override
  Stream<bool> get connectivityStream => _controller.stream;

  /// Updates the mock connectivity state.
  ///
  /// Not part of the production interface; useful for unit/widget tests.
  void setOnline(bool value) {
    _isOnline = value;
    _controller.add(_isOnline);
  }
}

