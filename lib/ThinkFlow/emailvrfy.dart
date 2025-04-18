import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:thinkflow/ThinkFlow/password.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key});

  @override
  _EmailVerificationScreenState createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifyEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final email = _emailController.text.trim();
      final methods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
      
      if (methods.isNotEmpty) {
        setState(() {
          _errorMessage = "This email is already registered. Try logging in.";
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Verification link sent to your email.")),
        );
        // Simulate sending verification email (Implement actual sending logic if needed)
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'invalid-email') {
          _errorMessage = "Invalid email format!";
        } else {
          _errorMessage = "Error: ${e.message}";
        }
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _continue() {
    if (_formKey.currentState!.validate() && _errorMessage == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PasswordScreen(emailId: _emailController.text.trim()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  children: [
                    Icon(Icons.arrow_back),
                    SizedBox(width: 5),
                    Text(
                      "Enter Your Email",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: _emailController,
                  validator: (value) =>
                      (value != null && value.contains("@")) ? null : "Enter a valid email",
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.email, color: Colors.black54),
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),
                const SizedBox(height: 15),
                Center(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _verifyEmail,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Verify", style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 30),
                Center(
                  child: GestureDetector(
                    onTap: _continue,
                    child: buildContinueButton('Continue', context),
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
