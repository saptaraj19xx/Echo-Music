import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'mock_connectivity_service.dart';
import 'service.dart';

/// Riverpod provider for [ConnectivityService].
///
/// This layer uses mock implementations only for Sprint 11.
final connectivityServiceProvider =
    Provider<ConnectivityService>((ref) => MockConnectivityService());

