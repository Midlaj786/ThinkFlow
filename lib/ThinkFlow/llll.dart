import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class MentorLoginPage extends StatefulWidget {
  const MentorLoginPage({super.key});

  @override
  _MentorLoginPageState createState() => _MentorLoginPageState();
}

class _MentorLoginPageState extends State<MentorLoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final picker = ImagePicker();
  String? selectedProfession;
  String? uid;
  File? _image;
  String? imageUrl;

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        uid = user.uid;
      });
      loadUserData();
    }
  }

  void loadUserData() async {
    if (uid == null) return;
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(uid).get();
    if (userDoc.exists) {
      setState(() {
        nameController.text = userDoc["name"] ?? "";
        selectedProfession = userDoc["profession"];
        experienceController.text = userDoc["experience"] ?? "";
        skillsController.text = userDoc["skills"] ?? "";
        imageUrl = userDoc["profileimg"] ?? "";
      });
    }
  }

  void submitMentorDetails(BuildContext context) async {
    if (uid == null) return;
    if (_image != null) {
      final ref =
          FirebaseStorage.instance.ref().child("mentor_profiles/$uid.jpg");
      await ref.putFile(_image!);
      imageUrl = await ref.getDownloadURL();
    }

    Map<String, dynamic> mentorData = {
      "name": nameController.text,
      "profession": selectedProfession,
      "experience": experienceController.text,
      "skills": skillsController.text,
      "uid": uid,
      "profileimg": imageUrl,
    };
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .update(mentorData);
    await FirebaseFirestore.instance
        .collection("mentors")
        .doc(uid)
        .set(mentorData);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mentor details updated successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Mentor Registration',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null
                      ? FileImage(_image!)
                      : (_image == null
                          ? null
                          : NetworkImage(imageUrl ??
                              "https://img.freepik.com/premium-vector/person-icon_109161-4674.jpg?w=740")),
                  child: _image == null
                      ? const Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        )
                      : null,
                ),
                Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.orange,
                      child: IconButton(
                        onPressed: () {
                          _pickImage();
                        },
                        icon: const Icon(Icons.camera_alt, color: Colors.white),
                      ),
                    )),
              ]),
            ),
            const SizedBox(height: 16),
            const Text(
              'Become a Mentor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: 'Full Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedProfession,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: 'Select Profession',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              items: [
                'Software Developer',
                'Data Scientist',
                'Graphic Designer',
                'Marketing Expert',
                'Other',
              ].map((profession) {
                return DropdownMenuItem(
                  value: profession,
                  child: Text(profession),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedProfession = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: experienceController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: 'Years of Experience',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: skillsController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[200],
                labelText: 'Skills & Expertise',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0)),
              ),
            ),
            const SizedBox(height: 24),
            Center(
                child: GestureDetector(
                    onTap: () {
                      submitMentorDetails(context);
                      Navigator.pop(context);
                    },
                    child: buildContinueButton("submit", context))),
          ],
        ),
      ),
    );
  }
}
