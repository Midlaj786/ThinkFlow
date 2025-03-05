import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:thinkflow/ThinkFlow/materialuplode.dart';

class Courseuplode extends StatefulWidget {
  @override
  _CourseuplodeState createState() => _CourseuplodeState();
}

class _CourseuplodeState extends State<Courseuplode> {
  File? _image;
  final picker = ImagePicker();
  double _rating = 0.0;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? imageUrl;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadCourse() async {
    try {
      String uid = _auth.currentUser?.uid ?? ""; // Get user ID
      String imageUrl = "";

      // Upload image if selected
      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child("course_images/${DateTime.now()}.jpg");
        await ref.putFile(_image!);
        imageUrl = await ref.getDownloadURL();
      }

      // Save details to Firestore
      await _firestore.collection('courses').add({
        'uid': uid,
        'category': _categoryController.text,
        'name': _nameController.text,
        'price': _priceController.text,
        'offerPrice': _offerPriceController.text,
        'rating': _rating,
        'imageUrl': imageUrl,
        // 'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Course Uploaded!")));

      // Clear fields after upload
      setState(() {
        _image = null;
        _categoryController.clear();
        _nameController.clear();
        _priceController.clear();
        _offerPriceController.clear();
        _rating = 0.0;
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
    String courseId = await _firestore.collection('courses').doc().id;
     Navigator.push(context,MaterialPageRoute(builder: (context) => UploadFilesPage(courseId:courseId ,)));
              
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Upload Course", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: _image == null ? Colors.black : null,
                  borderRadius: BorderRadius.circular(10),
                  image: _image != null
                      ? DecorationImage(
                          image: FileImage(_image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: _image == null
                    ? Icon(Icons.add_a_photo, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 10),
            _buildTextField("Course Category", _categoryController),
            _buildTextField("Course Name", _nameController),
            _buildTextField("Price", _priceController, isNumber: true),
            _buildTextField("Offer Price", _offerPriceController,
                isNumber: true),
            SizedBox(height: 10),
            Text("Rate this Course", style: TextStyle(fontSize: 16)),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Colors.amber),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: 
               
              _uploadCourse,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
              ),
              child: Text("Submit Course",
                  style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildTextField(String hintText, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
