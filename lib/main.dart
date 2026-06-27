import 'package:flutter/material.dart';

import 'package:echo/app/app.dart';
import 'package:echo/core/firebase/firebase_initializer.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await FirebaseInitializer.init();

  runApp(const EchoApp());
}