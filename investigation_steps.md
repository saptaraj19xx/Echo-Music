# Flutter Windows C2665 Investigation - Steps

## Goal
Find the minimum coordinated FlutterFire versions that fix Windows build failure in `firebase_auth_plugin.cpp` (MSVC C2665 involving `flutter::EncodableValue` / `std::variant`), for Flutter 3.41.2.

## Constraints
- No application code changes.
- No patching generated plugin C++ code.
- Upgrade only these packages:
  - firebase_core
  - firebase_auth
  - cloud_firestore
  - firebase_storage
- After each attempt:
  - flutter pub get
  - flutter analyze
  - flutter test
  - flutter build windows
- Revert `pubspec.yaml` if an attempt fails.

## Attempt matrix (to be filled)
- Attempt 1 (smallest coordinated bump):
  - firebase_core: 2.32.0 (no change)
  - firebase_auth: ^4.17.0
  - cloud_firestore: ^4.17.5
  - firebase_storage: 11.6.5 (no change)
  - Status: FAILED (pubspec constraint resolution conflicted with just_audio/web deps)



- Attempt 2:
  - Status: in progress (selecting the minimum coupled FlutterFire release train)


## Notes
- Use PowerShell-friendly commands on Windows.

