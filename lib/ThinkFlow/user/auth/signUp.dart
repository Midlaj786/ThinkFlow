import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkflow/thinkflow/user/auth/auth.dart';
import 'package:thinkflow/thinkflow/user/widgets/bottomNav.dart';
import 'package:thinkflow/thinkflow/user/widgets/widgets.dart';

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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  Future<void> _pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? returnImage = await _picker.pickImage(source: ImageSource.gallery);
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
    if (_formKey.currentState!.validate() && _selectedGender != null) {
      setState(() => _isLoading = true);
      try {
        final key = 'images/${DateTime.now().millisecondsSinceEpoch}.jpg';

        if (_profileImage != null) {
          File? compressedFile = await compressImage(_profileImage!);
          await Amplify.Storage.uploadFile(
            local: compressedFile ?? _profileImage!,
            key: key,
          );
        }

        final imageUrl = "https://thinkflowimages36926-dev.s3.us-east-1.amazonaws.com/public/$key";

        String uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          "name": _nameController.text,
          "email": FirebaseAuth.instance.currentUser!.email!,
          "dob": _dobController.text,
          "phone": _phoneController.text,
          "gender": _selectedGender!,
          "profileimg": imageUrl,
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
      } finally {
        setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all required fields!")),
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
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.arrow_back),
                      SizedBox(width: 5),
                      Text(
                        "Create Your Profile",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Stack(
                      children: [
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: selectedImage != null
                                ? MemoryImage(selectedImage!) // Web
                                : _profileImage != null
                                    ? FileImage(_profileImage!) // Mobile
                                    : null,
                            child: (selectedImage == null && _profileImage == null)
                                ? Icon(Icons.camera_alt, size: 40, color: Colors.grey[700])
                                : null,
                          ),
                        ),
                        const Positioned(
                          bottom: 5,
                          right: 5,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Colors.green,
                            child: Icon(Icons.edit, size: 14, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _nameController,
                    validator: (value) => value!.isEmpty ? "Name is required" : null,
                    decoration: _inputDecoration("First Name", Icons.person),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _dobController,
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _dobController.text = "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        });
                      }
                    },
                    validator: (value) => value!.isEmpty ? "Date of birth is required" : null,
                    decoration: _inputDecoration("Date of Birth", Icons.calendar_today),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) return "Phone number required";
                      if (value.length != 10) return "Enter a valid 10-digit number";
                      return null;
                    },
                    decoration: _inputDecoration("Phone Number", Icons.phone),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    validator: (value) => value == null ? "Gender is required" : null,
                    decoration: _inputDecoration("Gender", Icons.person_outline),
                    items: ['Male', 'Female', 'Other'].map((gender) {
                      return DropdownMenuItem(value: gender, child: Text(gender));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                      });
                    },
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : GestureDetector(
                            onTap: _saveDetails,
                            child: buildContinueButton('Continue', context),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Colors.black54),
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[200],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
