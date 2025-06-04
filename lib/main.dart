import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:thinkflow/thinkflow/user/auth/login.dart';
import 'package:thinkflow/thinkflow/user/widgets/splashscreen.dart';
import 'package:thinkflow/amplifyconfiguration.dart';
import 'package:thinkflow/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await configureAmplify(); // ✅ Await this!
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: MyApp(),
    ),
  );
}

bool _amplifyConfigured = false;

Future<void> configureAmplify() async {
  if (Amplify.isConfigured) return;

  try {
    final authPlugin = AmplifyAuthCognito();
    final storagePlugin = AmplifyStorageS3();

    await Amplify.addPlugins([authPlugin, storagePlugin]); // ✅ Add both
    await Amplify.configure(amplifyconfig); // ✅ Configure once
    print('✅ Amplify configured successfully');
  } catch (e) {
    print('❌ Could not configure Amplify: $e');
  }
}

class MyApp extends StatelessWidget {
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
