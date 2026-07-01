# TODO_PHASE3.md

## Phase C — Item Actions (Sprint 17)
- [ ] Add overflow (⋮) actions per Recently Played row: Play, Play Next, Add to Queue, Remove from History.
- [ ] Ensure remove calls LibraryRepository and relies on recentlyPlayedStreamProvider for UI updates.
- [ ] Reuse QueueNotifier + PlayerController, no new providers, no duplicated playback logic.

## Phase C — Playback Resume (Sprint 17 — Step 4)
- [x] Implement resume logic using RecentlyPlayed.lastPosition when starting playback from Recently Played.
- [ ] Refactor resume logic into a single reusable helper callable by the Recently Played page and future Continue Listening.
- [ ] Validate behavior when lastPosition >= duration or seeking fails (fallback to start).

