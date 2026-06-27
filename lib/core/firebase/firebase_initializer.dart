import 'package:firebase_core/firebase_core.dart';

import 'package:echo/firebase_options.dart';

/// Centralized Firebase initialization for the whole app.
class FirebaseInitializer {
  static bool _initialized = false;

  /// Initialize Firebase once.
  ///
  /// Safe to call multiple times.
  static Future<void> init() async {
    if (_initialized) return;

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    _initialized = true;
  }
}





