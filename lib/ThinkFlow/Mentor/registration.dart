import 'dart:io';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:thinkflow/thinkflow/user/widgets/widgets.dart';
class MentorLoginPage extends StatefulWidget {
  MentorLoginPage({super.key});

  @override
  _MentorLoginPageState createState() => _MentorLoginPageState();
}

class _MentorLoginPageState extends State<MentorLoginPage> {
   final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController _professionController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  bool isExistingMentor = false;
  String? uid;
  dynamic selectedImage;
  File? _image;
  String email = '';
  String profileImageUrl = '';
  String selectedProfession = "";
  bool isTypinProfession = false;
  List<String> professions = [];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedImage =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return; // Exit if no image is selected

    if (kIsWeb) {
      Uint8List imageBytes = await pickedImage.readAsBytes();
      setState(() {
        selectedImage = imageBytes;
      });
    } else {
      setState(() {
        _image = File(pickedImage.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchProfessions();
    getCurrentUser();
  }

  Future<void> _fetchProfessions() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection("mentors").get();
    Set<String> uniqueProfessions = {};
    for (var doc in snapshot.docs) {
      if (doc["profession"] != null) {
        uniqueProfessions.add(doc["profession"]);
      }
    }
    setState(() {
      professions = uniqueProfessions.toList();
    });
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

    DocumentSnapshot mentorDoc =
        await FirebaseFirestore.instance.collection("mentors").doc(uid).get();

    if (mentorDoc.exists) {
      // ✅ Already a mentor - load full mentor details
      setState(() {
        isExistingMentor = true;
        nameController.text = mentorDoc["name"] ?? "";
        selectedProfession = mentorDoc["profession"] ?? "";
        _professionController.text = selectedProfession;
        experienceController.text = mentorDoc["experience"] ?? "";
        skillsController.text = mentorDoc["skills"] ?? "";
        profileImageUrl = mentorDoc["profileimg"] ?? "";
        email = mentorDoc["email"] ?? "";
      });
    } else {
      // ❗ Not a mentor - load only basic user info
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (userDoc.exists) {
        setState(() {
          nameController.text = userDoc["name"] ?? "";
          profileImageUrl = userDoc["profileimg"] ?? "";
          email = userDoc["email"] ?? "";
        });
      }
    }
  }

  void submitMentorDetails(BuildContext context) async {
     if (!_formKey.currentState!.validate()) return;
    if (uid == null) return;

    // String imageUrl = profileImageUrl;
    String finalProfession = _professionController.text;
    
    String imageUrl = profileImageUrl;

    
    // Upload image to S3
    if (_image != null) {
      final key = 'mentor_profiles/${DateTime.now().millisecondsSinceEpoch}.jpg';
      File? compressedFile = await compressImage(_image!);

      final UploadFileResult result = await Amplify.Storage.uploadFile(
        local: compressedFile ?? _image!,
        key: key,
      );
       imageUrl =
        "https://thinkflowimages36926-dev.s3.us-east-1.amazonaws.com/public/$key";

    }

    
    Map<String, dynamic> mentorData = {
      "name": nameController.text,
      "profession": finalProfession,
      "experience": experienceController.text,
      "skills": skillsController.text,
      "uid": uid,
      "profileimg": imageUrl,
      "email": email,
    };

    // await FirebaseFirestore.instance.collection("users").doc(uid).update({
    //   "name": nameController.text,
    //   "profileimg": imageUrl,
    // });
    if (isExistingMentor) {
      await FirebaseFirestore.instance
          .collection("mentors")
          .doc(uid)
          .update(mentorData);
    } else {
      await FirebaseFirestore.instance
          .collection("mentors")
          .doc(uid)
          .set(mentorData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Mentor details updated successfully!")),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          isExistingMentor ? 'Update Profile' : 'Mentor Registration',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: themeProvider.textColor,
          ),
        ),
       
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      backgroundImage: selectedImage != null
                          ? MemoryImage(selectedImage!) as ImageProvider
                          : (_image != null
                              ? FileImage(_image!) as ImageProvider
                              : (profileImageUrl.isNotEmpty
                                  ? NetworkImage(profileImageUrl)
                                  : null)),
                      child: (selectedImage == null &&
                              _image == null &&
                              profileImageUrl.isEmpty)
                          ? Icon(Icons.person, size: 50, color: Colors.white)
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
                            icon:
                                const Icon(Icons.camera_alt, color: Colors.white),
                          ),
                        )),
                  ]),
                ),
                const SizedBox(height: 16),
                Text(
                  isExistingMentor
                      ? 'Update Your Mentor Profile'
                      : 'Become a Mentor',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Full Name is required' : null,
      
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: themeProvider.isDarkMode
                        ? Colors.grey[500]
                        : Colors.grey[100],
                    labelText: 'Full Name',
                    labelStyle: TextStyle(color: themeProvider.textColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                const SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Autocomplete<String>(
                      optionsBuilder: (TextEditingValue textEditingValue) {
                        if (textEditingValue.text.isEmpty) {
                          return professions;
                        }
                        return professions.where((category) => category
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()));
                      },
                      onSelected: (String selection) {
                        setState(() {
                          _professionController.text = selection;
                          selectedProfession = selection;
                        });
                      },
                      fieldViewBuilder:
                          (context, controller, focusNode, onEditingComplete) {
                        controller.text =
                            _professionController.text; // Keep previous value
                        return TextFormField(
                          controller: _professionController,
                          focusNode: focusNode,
                           validator: (value) =>
                        value == null || value.trim().isEmpty ? 'Profession is required' : null,
                   
                          onEditingComplete: onEditingComplete,
                          onChanged: (value) {
                            setState(() {
                              selectedProfession =
                                  value; // Allow new category input
                            });
                          },
                          decoration: InputDecoration(
                            labelText: "Profession",
                            labelStyle: TextStyle(color: themeProvider.textColor),
                            filled: true,
                            fillColor: themeProvider.isDarkMode
                                ? Colors.grey[500]
                                : Colors.grey[100],
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: experienceController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: themeProvider.isDarkMode
                        ? Colors.grey[500]
                        : Colors.grey[100],
                    labelText: 'Years of Experience',
                    labelStyle: TextStyle(color: themeProvider.textColor),
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
                    fillColor: themeProvider.isDarkMode
                        ? Colors.grey[500]
                        : Colors.grey[100],
                    labelText: 'Skills & Expertise',
                    labelStyle: TextStyle(color: themeProvider.textColor),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                    child: GestureDetector(
                        onTap: () => submitMentorDetails(context),
                          
                        
                        child: buildContinueButton("submit", context))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
