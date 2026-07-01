# TODO_PHASE4 — Phase D (Most Played Stream Layer)

- [x] Create `lib/features/library/providers/most_played_stream_provider.dart`
  - [x] Implement `mostPlayedStreamProvider` as a single `StreamProvider<List<MostPlayed>>`
  - [x] Back with `LibraryRepository.watchMostPlayed()` via `libraryRepositoryProvider`
  - [x] Preserve Riverpod loading/error behavior (StreamProvider defaults)
  - [x] Avoid autoDispose
- [ ] (Phase E) Update Most Played page and Home “Most Played” card to consume `mostPlayedStreamProvider`

