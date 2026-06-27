# Firestore Seeder (Sprint 12.5)

Reusable development seeder for Firestore.

## Run

```bash
dart run lib/tools/seeder/run_seed.dart
```

## Overwrite existing documents

```bash
dart run lib/tools/seeder/run_seed.dart --overwrite=true
```

- Default: `overwrite=false`
- When `overwrite=false`: skips documents that already exist (idempotent)
- When `overwrite=true`: replaces documents with the generated data

## Output

Seeder prints:

- ✓ Genres
- ✓ Artists
- ✓ Albums
- ✓ Songs
- ✓ Playlists

and then:

- `Seeder completed successfully.`

## Validation

Run:

- `flutter analyze`
- `flutter test`

