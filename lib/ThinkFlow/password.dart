import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thinkflow/ThinkFlow/auth.dart';
import 'package:thinkflow/ThinkFlow/bottomNav.dart';
import 'package:thinkflow/ThinkFlow/home.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class PasswordScreen extends StatefulWidget {
  final Map<String, dynamic> userDetails;

  PasswordScreen({required this.userDetails});

  @override
  _PasswordScreenState createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // final Map userDetails = ;

  final AuthService _authService = AuthService();

  void _submitPassword() async {
    if (_passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showSnackBar("Password fields cannot be empty!");
      return;
    }
    // if (widget.userDetails.containsKey('email')) {
    //   _showSnackBar("Email is required");

    //   return;
    // }

    if (_passwordController.text.length < 6) {
      _showSnackBar("Password must be at least 6 characters!");

      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords do not match!");

      return;
    }

    try {
      UserCredential userCredential = await _authService.signUp(
              widget.userDetails['email'], _passwordController.text)
          as UserCredential;

      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;
        _saveDetails(uid);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );

        _showSnackBar("Signup Completed Successfully!");
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      if (e.code == 'email-already-in-use') {
        errorMessage = "This email is already registered. Try logging in.";
      } else if (e.code == 'invalid-email') {
        errorMessage = "Invalid email format!";
      } else if (e.code == 'weak-password') {
        errorMessage = "Password is too weak. Use a stronger password.";
      } else {
        errorMessage = "Error: ${e.message}";
      }
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(errorMessage)));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Unknown Error: ${e.toString()}")),
      );
    }
  }

  void _saveDetails(String uid) async {
    await _authService.saveDetails(
      uid: uid,
      name: widget.userDetails['name'] ?? "Unknown",
      dob: widget.userDetails['dob'] ?? "N/A",
      email: widget.userDetails['email'] ?? "N/A",
      phone: widget.userDetails['phone'] ?? "N/A",
      gender: widget.userDetails['gender'] ?? "N/A",
      profileImage: widget.userDetails['profileImage'] ?? "",
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Create a Password',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Create a Strong Password to Make Your\nAccount more Secure',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            SizedBox(height: 30),
            _buildPasswordField(
                _passwordController, "Password", _obscurePassword, () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            }),
            SizedBox(height: 16),
            _buildPasswordField(_confirmPasswordController,
                "Confirm your Password", _obscureConfirmPassword, () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            }),
            SizedBox(height: 32),
            Center(
              child: GestureDetector(
                onTap: _submitPassword,
                child: buildContinueButton("Continue", context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String label,
      bool obscure, VoidCallback toggleVisibility) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          labelStyle: TextStyle(color: Colors.black54, fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.lock, color: Colors.grey),
          suffixIcon: IconButton(
            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey),
            onPressed: toggleVisibility,
          ),
        ),
      ),
    );
  }
}
