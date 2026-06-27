import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../firestore_adapter.dart';

/// Riverpod provider for [FirestoreAdapter].
final firestoreAdapterProvider = Provider<FirestoreAdapter>((ref) {
  return FirestoreAdapter();
});

