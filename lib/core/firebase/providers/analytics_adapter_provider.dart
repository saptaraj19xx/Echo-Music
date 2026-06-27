import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../analytics_adapter.dart';

/// Riverpod provider for [AnalyticsAdapter].
final analyticsAdapterProvider = Provider<AnalyticsAdapter>((ref) {
  return AnalyticsAdapter();
});

