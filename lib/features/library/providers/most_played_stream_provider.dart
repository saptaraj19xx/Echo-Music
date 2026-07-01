import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:echo/features/library/domain/entities/most_played.dart';
import 'package:echo/features/library/domain/repositories/library_repository.dart';
import 'package:echo/features/library/presentation/providers/library_providers.dart';

/// Single source of truth for Most Played list.
///
/// Data flow:
/// Firestore -> LibraryRepository.watchMostPlayed() -> this provider -> UI.
final mostPlayedStreamProvider = StreamProvider<List<MostPlayed>>(
  (ref) {
    final repository = ref.watch(libraryRepositoryProvider);
    return repository.watchMostPlayed();
  },
);

