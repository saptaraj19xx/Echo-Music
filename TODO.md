# TODO - Coordinated FlutterFire upgrade (Windows C2665)

- [x] Step 1: Create coordinated FlutterFire release-train version bump in `pubspec.yaml` (firebase_core, firebase_auth, cloud_firestore, firebase_storage only).
- [ ] Step 2: Run `flutter pub get`.
- [ ] Step 3: Run `flutter analyze`.
- [ ] Step 4: Run `flutter test`.
- [ ] Step 5: Run `flutter build windows`.
- [ ] Step 6: If Windows build succeeds, report exact resolved package versions.
- [x] Step 7: If Windows build fails, report the new compiler error and stop.
- [x] Windows build failed with C2665 in firebase_auth_plugin.cpp; stopping per requirements.


