import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:thinkflow/thinkflow/user/auth/login.dart';
import 'package:thinkflow/thinkflow/user/widgets/bottomNav.dart';

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {

    super.initState();
     _checkLoginStatus();
   
  }
  
  void _checkLoginStatus() async {
    await Future.delayed(Duration(seconds: 3)); // Just to show splash briefly

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => MainScreen()));
    } else {
      
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginScreen()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/thinkflow_splash_watermark.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  'assets/logo.png',
                  height: 120,
                ),
                SizedBox(height: 24),

                // App Name
                Text(
                  'THINKFLOW',
                  style: TextStyle(
                    fontSize: 37,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.orange,
                  ),
                ),

                SizedBox(height: 10),

                // Slogan
                Text(
                  'Empowering Learning, Anytime, Anywhere',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey[700],
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
