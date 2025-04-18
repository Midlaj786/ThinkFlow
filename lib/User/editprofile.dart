import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

Future<File?> cropImage(File imageFile) async {
  CroppedFile? croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    aspectRatioPresets: [
      CropAspectRatioPreset.square,
      CropAspectRatioPreset.ratio3x2,
      CropAspectRatioPreset.original,
      CropAspectRatioPreset.ratio4x3,
      CropAspectRatioPreset.ratio16x9,
    ],
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Crop Image',
        toolbarColor: Colors.orange,
        toolbarWidgetColor: Colors.white,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: 'Crop Image',
        minimumAspectRatio: 1.0,
      ),
    ],
  );

  // ✅ Return file only if cropping is successful
  return croppedFile != null ? File(croppedFile.path) : null;
}

class EditProfilePage extends StatefulWidget {
  EditProfilePage({super.key});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedGender = "Male";
  DateTime? _selectedDob;
  String profileImageUrl = "";
  bool _isLoading = false;
  File? _image;
  dynamic selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _nameController.text = userDoc['name'] ?? "";
          _phoneController.text = userDoc['phone'] ?? "";
          _selectedGender = userDoc['gender'] ?? "Male";
          profileImageUrl = userDoc['profileimg'] ?? "";
          _selectedDob =
              userDoc['dob'] != null ? DateTime.parse(userDoc['dob']) : null;
        });
      }
    }
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String imageUrl = profileImageUrl; // Keep old image if not updated
      final FirebaseStorage storage =
          FirebaseStorage.instanceFor(bucket: "gs://thinkflow");
      if (selectedImage != null) {
        final ref = storage.ref().child(
            "users_profile/${DateTime.now().microsecondsSinceEpoch}.jpg");
        UploadTask uploadTask = ref.putData(
            selectedImage, SettableMetadata(contentType: 'image/jpeg'));
        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }
      await FirebaseFirestore.instance
          .collection('mentors')
          .doc(user.uid)
          .update({
        'profileimg': imageUrl,
      });
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'name': _nameController.text,
        'phone': _phoneController.text,
        'gender': _selectedGender,
        'dob': _selectedDob != null ? _selectedDob!.toIso8601String() : null,
        'profileimg': imageUrl,
      });

      setState(() {
        profileImageUrl = imageUrl;
        selectedImage = null;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile Updated Successfully!")),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile == null) return; // No image selected

    if (kIsWeb) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        selectedImage = imageBytes;
      });
    } else {
      File imageFile = File(pickedFile.path);
      File? croppedFile = await cropImage(imageFile); // ✅ Use global function
      if (croppedFile != null) {
        setState(() {
          _image = croppedFile;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDob = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Edit Profile",
            style: TextStyle(
                color: themeProvider.textColor, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
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
                                ? Icon(Icons.person,
                                    size: 50, color: Colors.white)
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: CircleAvatar(
                                radius: 18,
                                backgroundColor: themeProvider.backgroundColor,
                                child: Icon(Icons.edit,
                                    color: themeProvider.textColor),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30),
                    _buildTextField(
                        "Name", _nameController, Icons.person, themeProvider),
                    _buildTextField("Phone Number", _phoneController,
                        Icons.phone, themeProvider),
                    _buildGenderDropdown(themeProvider),
                    _buildDatePicker(context, themeProvider),
                    SizedBox(height: 40),
                    GestureDetector(
                        onTap: () {
                          _updateProfile();
                          Navigator.pop(context);
                        },
                        child: buildContinueButton("Save Changes", context))
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      IconData icon, ThemeProvider themeProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.orange),
          labelText: label,
          labelStyle: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          filled: true,
          fillColor:
              themeProvider.isDarkMode ? Colors.grey[500] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderDropdown(ThemeProvider themeProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: DropdownButtonFormField<String>(
        value: _selectedGender,
        items: ["Male", "Female", "Other"].map((String gender) {
          return DropdownMenuItem<String>(
            value: gender,
            child: Text(gender),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedGender = value!;
          });
        },
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: Colors.orange),
          labelText: "Gender",
          labelStyle: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          filled: true,
          fillColor:
              themeProvider.isDarkMode ? Colors.grey[500] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, ThemeProvider themeProvider) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        readOnly: true,
        controller: TextEditingController(
          text: _selectedDob != null
              ? DateFormat('yyyy-MM-dd').format(_selectedDob!)
              : "",
        ),
        onTap: () => _selectDate(context),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.calendar_today, color: Colors.orange),
          labelText: "Date of Birth",
          labelStyle: TextStyle(
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
          ),
          filled: true,
          fillColor:
              themeProvider.isDarkMode ? Colors.grey[500] : Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
