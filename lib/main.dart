import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:thinkflow/ThinkFlow/bottomNav.dart';
import 'package:thinkflow/ThinkFlow/course.dart';
import 'package:thinkflow/ThinkFlow/courseuplode.dart';
import 'package:thinkflow/ThinkFlow/llll.dart';
import 'package:thinkflow/ThinkFlow/login.dart';
import 'package:thinkflow/ThinkFlow/mentor.dart';
import 'package:thinkflow/ThinkFlow/mentorLog.dart';
import 'package:thinkflow/ThinkFlow/profail.dart';
import 'package:thinkflow/ThinkFlow/review.dart';
import 'package:thinkflow/ThinkFlow/signUp.dart';
import 'package:thinkflow/firebase_options.dart';

import 'ThinkFlow/materialuplode.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
