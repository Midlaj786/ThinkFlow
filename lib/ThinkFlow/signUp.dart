import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkflow/ThinkFlow/auth.dart';
import 'package:thinkflow/ThinkFlow/password.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  TextEditingController _nameController = TextEditingController();
  // TextEditingController _lastNameController = TextEditingController();
  TextEditingController _dobController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  // String? _password;
  String? _selectedGender;
  File? _profileImage;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  // void _registerUser() async {
  //   try {
  //     UserCredential userCredential =
  //         await FirebaseAuth.instance.createUserWithEmailAndPassword(
  //       email: _emailController.text,
  //       password: _password!,
  //     );
  //     await FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(userCredential.user!.uid)
  //         .set({
  //       "firstName": _firstNameController.text,
  //       // "lastName": _lastNameController.text,
  //       "dob": _dobController.text,
  //       "email": _emailController.text,
  //       "phone": _phoneController.text,
  //       "password": _password!,
  //       "gender": _selectedGender!,
  //       "uid": userCredential.user!.uid,
  //       "Profileimage": _profileImage.toString()
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Signup Successful!")),
  //     );

  //     Navigator.pushReplacementNamed(context, '/home');
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Signup Failed: ${e.toString()}")),
  //     );
  //   }
  // }
  // void _saveDetails() async {
  //   print(_dobController.text);
  //   print(_emailController.text);
  //   print(_phoneController.text);
  //   print(_selectedGender);
  //   if (_formKey.currentState!.validate() && _selectedGender != null) {
  //     await _authService.saveDetails(
  //       firstName: _firstNameController.text,
  //       // lastName: _lastNameController.text,
  //       dob: _dobController.text,
  //       email: _emailController.text,
  //       phone: _phoneController.text,
  //       gender: _selectedGender!,
  //       // profileImage: _profileImage?.path ?? '',
  //       // password: _password!,
  //     );
  //   }

  //   // void _handleSignUp() async {
  //   //   if (_formKey.currentState!.validate()) {
  //   //     String? password = await _authService.s(
  //   //         firstName: _firstNameController.text,
  //   //         lastName: _lastNameController.text,
  //   //         dob: _dobController.text,
  //   //         email: _emailController.text,
  //   //         phone: _phoneController.text,
  //   //         password: _password!,
  //   //         gender: _selectedGender!,

  //   //         Profileimage: _profileImage.toString());
  //   //   }
  //   //   else {
  //   //     ScaffoldMessenger.of(context).showSnackBar(
  //   //       SnackBar(content: Text("Please set a password!")),
  //   //     );
  //   //   }
  // }
  // Future<void> _navigateToPasswordScreen() async {
  //   if (_formKey.currentState!.validate()) {
  //     String? password = await Navigator.push(
  //       context,
  //       MaterialPageRoute(builder: (context) => PasswordScreen()),
  //     );
  //     if (password != null) {
  //       setState(() {
  //         _password = password; // ✅ Store returned password
  //       });
  //       // _registerUser();
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF8),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(Icons.arrow_back),
                    SizedBox(width: 5),
                    Text(
                      "Create Your Profile",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage(ImageSource.gallery);
                        },
                        child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: _profileImage != null
                                ? FileImage(_profileImage!)
                                : null,
                            child: _profileImage == null
                                ? Icon(Icons.camera_alt,
                                    size: 40, color: Colors.grey[700])
                                : null),
                      ),
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: CircleAvatar(
                          radius: 14,
                          backgroundColor: Colors.green,
                          child:
                              Icon(Icons.edit, size: 14, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      value!.isEmpty ? "Name is required" : null,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person, color: Colors.black54),
                    hintText: "First Name",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                // SizedBox(height: 15),
                // TextFormField(
                //   controller: _lastNameController,
                //   decoration: InputDecoration(
                //     prefixIcon: Icon(Icons.person, color: Colors.black54),
                //     hintText: "Last Name",
                //     filled: true,
                //     fillColor: Colors.grey[200],
                //     border: OutlineInputBorder(
                //       borderRadius: BorderRadius.circular(10),
                //       borderSide: BorderSide.none,
                //     ),
                //   ),
                // ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _dobController,
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.calendar_today, color: Colors.black54),
                    labelText: "Date of Birth",
                    hintText: "DD/MM/YYYY",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  validator: (value) =>
                      value!.contains("@") ? null : "Enter a valid email",
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.email, color: Colors.black54),
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) => value!.length == 10
                      ? null
                      : "Enter a valid 10-digit number",
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.phone, color: Colors.black54),
                    hintText: "Phone Number",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon:
                        Icon(Icons.person_outline, color: Colors.black54),
                    hintText: "Gender",
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items:
                      <String>['Male', 'Female', 'Other'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue;
                    });
                  },
                ),
                SizedBox(height: 30),
                Center(
                    child: GestureDetector(
                        onTap: () {},
                        child: GestureDetector(
                            onTap: () {
                              Map<String, dynamic> userDetails = {
                                "name": _nameController.text,
                                "dob": _dobController.text,
                                "email": _emailController.text,
                                "phone": _phoneController.text,
                                "gender": _selectedGender!,
                                "profileimage": _profileImage.toString(),
                              };
                              print('@@@@@@@@@@@@@@@@@@@@@@@');
                              print(userDetails);
                              if (_formKey.currentState!.validate() &&
                                  _selectedGender != null) {
                                // _saveDetails();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PasswordScreen(
                                        userDetails: userDetails),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text("Please fill in all fields!")),
                                );
                              }
                            },
                            // _showPasswordDialog();

                            child: buildContinueButton('Continue', context)))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
