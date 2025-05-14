import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/ThinkFlow/administration/onlinecall.dart';
import 'package:thinkflow/ThinkFlow/administration/payment.dart';
import 'package:thinkflow/User/login.dart';
import 'package:thinkflow/User/searchcourse.dart';
import 'package:thinkflow/ThinkFlow/searchmentor.dart';
import 'package:thinkflow/User/splashscreen.dart';
import 'package:thinkflow/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // themeMode: Provider.of<ThemeProvider>(context).themeMode,
      // theme: ThemeData.light(),
      // darkTheme: ThemeData.dark(),
      home: SplashScreen(),
      routes: {
        '/login': (context) => LoginScreen(),
        
      },
    );
  }
}
