import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light;

  bool get isDarkMode => themeMode == ThemeMode.dark;
   Color get backgroundColor => isDarkMode ? Colors.black : Colors.white;
  Color get textColor => isDarkMode ? Colors.white : Colors.black;
  Color get buttonColor => isDarkMode ? Colors.grey[800]! : Colors.blue;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists && userDoc['isDarkMode'] != null) {
        bool isDark = userDoc['isDarkMode'];
        themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    }
  }

  Future<void> toggleTheme() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      bool newDarkMode = !isDarkMode;
      themeMode = newDarkMode ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'isDarkMode': newDarkMode});
    }
  }
}
