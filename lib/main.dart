import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'src/core/services/first_launch_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final isFirstLaunch = await FirstLaunchService.isFirstLaunch();

  runApp(RumourApp(isFirstLaunch: isFirstLaunch));
}
