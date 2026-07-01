import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/features/library/domain/entities/recently_played.dart';
import 'package:echo/features/library/domain/repositories/library_repository.dart';
import 'package:echo/features/library/presentation/providers/library_providers.dart';

/// Single source of truth for Recently Played list.
///
/// Data flow:
/// Firestore -> LibraryRepository.watchRecentlyPlayed() -> this provider -> UI.
final recentlyPlayedStreamProvider = StreamProvider<List<RecentlyPlayed>>(

  (ref) {
    final repository = ref.watch(libraryRepositoryProvider);
    return repository.watchRecentlyPlayed();
  },
);

