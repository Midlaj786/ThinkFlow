import 'dart:io';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkflow/ThinkFlow/auth.dart';
import 'package:thinkflow/ThinkFlow/bottomNav.dart';
import 'package:thinkflow/ThinkFlow/password.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _selectedGender;
  File? _profileImage;
  dynamic selectedImage;
  String? _imageUrl;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? returnImage =
        await _picker.pickImage(source: ImageSource.gallery);

    if (returnImage == null) return;
    if (kIsWeb) {
      Uint8List imageBytes = await returnImage.readAsBytes();
      setState(() {
        selectedImage = imageBytes;
      });
    } else {
      setState(() {
        _profileImage = File(returnImage.path);
      });
    }
  }

  void _saveDetails() async {
    final FirebaseStorage storage =
        FirebaseStorage.instanceFor(bucket: "gs://thinkflow");
    if (selectedImage != null) {
      final ref = storage
          .ref()
          .child("users_profile/${DateTime.now().microsecondsSinceEpoch}.jpg");
      UploadTask uploadTask = ref.putData(
          selectedImage, SettableMetadata(contentType: 'image/jpeg'));
      TaskSnapshot taskSnapshot = await uploadTask;
      _imageUrl = await taskSnapshot.ref.getDownloadURL();
    }

    if (_formKey.currentState!.validate() && _selectedGender != null) {
      try {
        String uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          "name": _nameController.text,
          "email": FirebaseAuth.instance.currentUser!.email!,
          "dob": _dobController.text,
          "phone": _phoneController.text,
          "gender": _selectedGender!,
          "profileimg": _imageUrl,
          "uid": uid,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Signup Successful!")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Signup Failed: ${e.toString()}")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields!")),
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
          scrollDirection: Axis.vertical,
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
                      "Create Your Profile",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    children: [
                      GestureDetector(
                        onTap: () {
                          _pickImage();
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey[300],
                          backgroundImage: selectedImage != null
                              ? MemoryImage(selectedImage!) // Web
                              : _profileImage != null
                                  ? FileImage(_profileImage!) // Mobile
                                  : null,
                          child:
                              (selectedImage == null && _profileImage == null)
                                  ? Icon(Icons.camera_alt,
                                      size: 40, color: Colors.grey[700])
                                  : null,
                        ),
                      ),
                      const Positioned(
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _nameController,
                  validator: (value) =>
                      value!.isEmpty ? "Name is required" : null,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person, color: Colors.black54),
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
                const SizedBox(height: 15),
                TextFormField(
                  controller: _dobController,
                  readOnly: true, // Prevents manual input
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900), // Earliest selectable date
                      lastDate: DateTime.now(), // Latest selectable date
                    );
                    if (pickedDate != null) {
                      String formattedDate =
                          "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                      setState(() {
                        _dobController.text =
                            formattedDate; // Updates the text field
                      });
                    }
                  },
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.black54),
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

                const SizedBox(height: 15),
                TextFormField(
                  controller: _phoneController,
                  validator: (value) => value!.length == 10
                      ? null
                      : "Enter a valid 10-digit number",
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.phone, color: Colors.black54),
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
                const SizedBox(height: 15),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.black54),
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
                const SizedBox(height: 30),
                Center(
                    child: GestureDetector(
                        onTap: () {},
                        child: GestureDetector(
                            onTap: () {
                              _saveDetails();
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
