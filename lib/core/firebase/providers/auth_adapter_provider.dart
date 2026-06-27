import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_adapter.dart';

/// Riverpod provider for [AuthAdapter].
final authAdapterProvider = Provider<AuthAdapter>((ref) {
  return AuthAdapter();
});

