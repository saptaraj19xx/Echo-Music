# TODO

## Recently Played rich write API
- [ ] Add new entry API to LibraryRepository: `addRecentlyPlayedEntry({...})` with richer metadata.
- [ ] Keep `addRecentlyPlayed(String songId)` for backward compatibility.
- [ ] Update `FirestoreLibraryRepositoryImpl` to implement the new method and delegate old one to it.
- [ ] Update `RecentlyPlayedTracker` (and any other call sites) to use the new write API going forward.
- [ ] Ensure Firestore write contains the richer fields (duration, lastPosition, playedAt, title/artist/artworkUrl).
- [ ] Run `flutter analyze` (and tests if present) to confirm compilation.

