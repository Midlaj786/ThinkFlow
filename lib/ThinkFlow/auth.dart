import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance; // Add Firestore instance

  Future<UserCredential?> signUp(String email, String password) async {
    try {
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential; // Success
    } catch (e) {
      print(e); // Return error message
    }
  }

  // Sign Up with Email & Password and Save Details
  Future<void> saveDetails({
    required String uid,
    required String name,
    required String dob,
    required String email,
    required String phone,
    required String gender,
    required String profileImage,
  }) async {
    try {
      Map<String, dynamic> userdata = {
        "name": name,
        "dob": dob,
        "email": email,
        "phone": phone,
        "gender": gender,
        "uid": uid,
        "profileimg": profileImage,
      };

      await _firestore.collection("users").doc(uid).set(userdata);
    } catch (e) {
      print("Error saving user details: $e");
    }
  }

  // try {
  //   UserCredential userCredential =
  //       await _auth.createUserWithEmailAndPassword(
  //     email: email,
  //     password: password,
  //   );

  //     // Save User Details in Firestore
  //     await _firestore.collection("users").doc(userCredential.user!.uid).set({
  //       "firstName": firstName,
  //       "lastName": lastName,
  //       "dob": dob,
  //       "email": email,
  //       "phone": phone,
  //       "gender": gender,
  //       "Profileimage": Profileimage,
  //       "uid": userCredential.user!.uid,
  //     });

  //     return null; // Success
  //   } catch (e) {
  //     return e.toString(); // Return error message
  //   }
  // }

  // // Login with Email & Password
  // Future<String?> login(String email, String password) async {
  //   try {
  //     await _auth.signInWithEmailAndPassword(email: email, password: password);
  //     return null; // Success
  //   } catch (e) {
  //     return e.toString(); // Return error message
  //   }
  // }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      return credential.user; // Success
    } catch (e) {
      print(e); // Return error message
    }
  }

  // Google Sign-In
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return "Google sign-in aborted";

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      String? uid = userCredential.user!.uid;

      // Save Google user details to Firestore (if not already saved)
      DocumentSnapshot userDoc =
          await _firestore.collection("users").doc(uid).get();
      if (!userDoc.exists) {
        await _firestore.collection("users").doc(uid).set({
          "firstName": googleUser.displayName ?? "Unknown",
          "email": googleUser.email,
          "uid": uid,
        });
      }

      return null; // Success
    } catch (e) {
      return e.toString(); // Return error message
    }
  }

  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
}
