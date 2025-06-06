import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:thinkflow/thinkflow/user/auth/auth.dart';
import 'package:thinkflow/thinkflow/user/auth/emailvrfy.dart';
import 'package:thinkflow/thinkflow/user/widgets/bottomNav.dart';
import 'package:thinkflow/thinkflow/user/widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  bool _obscurePassword = true;
  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      User? result = await _authService.loginWithEmail(
        _emailController.text,
        _passwordController.text,
      );

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!")),
        );
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => const MainScreen()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.toString())),
        );
      }
    }
  }

  // void _handleGoogleLogin() async {
  //   String? result = await _authService.signInWithGoogle(context);
  //   print('8888888888888');
  //   print(result);
  //   print('8888888888888');
  //   if (result == null) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       const SnackBar(content: Text("Google Sign-In Successful!")),
  //     );
  //     if (FirebaseAuth.instance.currentUser != null) {
  //       Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => const MainScreen()));
  //     } else {
  //       Navigator.push(context,
  //           MaterialPageRoute(builder: (context) => const SignupScreen()));
  //     }
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(result)),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, color: Colors.orange, size: 30),
            SizedBox(width: 5),
            Text(
              "ThinkFlow",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Getting Started.!",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _emailController,
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
              const SizedBox(height: 15),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock, color: Colors.black54),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.black54,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),
              GestureDetector(
                  onTap: () {
                    _handleLogin();
                  },
                  child: buildContinueButton("Continue", context)),
              const SizedBox(height: 20),
              const Text("Or Continue With",
                  style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Google Button
                  GestureDetector(
                    onTap: () async {
                      print('kkkkkkkkkkkkkkkkk');
                      await _authService.signInWithGoogle(context);
                    },
                    child: const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white,
                      child: Icon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                        size: 22,
                      ),
                    ),
                  ),
                  // const SizedBox(width: 20),

                  // GestureDetector(
                  //   onTap: () {
                  //     fetchUserData();
                  //     // deleteAllMessages();
                  //     // deleteCollection('chats');
                  //     // deleteCollection('messages');
                  //     // deleteCollection("mentors");
                  //     // deleteAllFromCollection('messsages');

                  //   },
                  //   child: const CircleAvatar(
                  //     radius: 22,
                  //     backgroundColor: Colors.blue,
                  //     child: Icon(
                  //       FontAwesomeIcons.facebook,
                  //       color: Colors.white,
                  //       size: 22,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an Account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const EmailVerificationScreen()));
                    },
                    child: const Text(
                      "SIGN UP",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> deleteAllMessages() async {
  CollectionReference messagesCollection =
      FirebaseFirestore.instance.collection('messages');

  QuerySnapshot messagesSnapshot = await messagesCollection.get();

  for (DocumentSnapshot chatDoc in messagesSnapshot.docs) {
    String chatId = chatDoc.id;

    // Delete all messages inside each chatId's "chats" subcollection
    CollectionReference chatMessagesRef =
        messagesCollection.doc(chatId).collection('chats');
    QuerySnapshot chatMessagesSnapshot = await chatMessagesRef.get();

    for (DocumentSnapshot messageDoc in chatMessagesSnapshot.docs) {
      await messageDoc.reference.delete();
    }

    // Delete the chatId document itself
    await chatDoc.reference.delete();
  }

  print("🔥 Messages collection deleted successfully!");
}

// Call this function to delete all messages

Future<void> deleteCollection(String collectionPath) async {
  var collection = FirebaseFirestore.instance.collection(collectionPath);

  var snapshots = await collection.get();
  for (var doc in snapshots.docs) {
    await doc.reference.delete();
  }

  print("Collection '$collectionPath' deleted successfully.");
}

void fetchUserData() async {
  String userId = FirebaseAuth.instance.currentUser!.uid;

  DocumentSnapshot userDoc = await FirebaseFirestore.instance
      .collection('users') // Adjust collection name if different
      .doc(userId)
      .get();

  if (userDoc.exists) {
    print("User Data: ${userDoc.data()}"); // ✅ Check if data is retrieved
  } else {
    print("No user data found"); // ❌ Indicates missing data in Firestore
  }
}

Future<void> deleteAllFromCollection(String collectionName) async {
  final collection = FirebaseFirestore.instance.collection(collectionName);

  // Get all documents in the collection
  final snapshots = await collection.get();

  // Delete each document
  for (var doc in snapshots.docs) {
    await doc.reference.delete();
  }
}
