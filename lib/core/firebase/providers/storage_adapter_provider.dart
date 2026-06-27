import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage_adapter.dart';

/// Riverpod provider for [StorageAdapter].
final storageAdapterProvider = Provider<StorageAdapter>((ref) {
  return StorageAdapter();
});

