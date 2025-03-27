import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class CourseUpload extends StatefulWidget {
  final String? courseId;
  CourseUpload({super.key, this.courseId});

  @override
  _CourseUploadState createState() => _CourseUploadState();
}

class _CourseUploadState extends State<CourseUpload> {
  dynamic selectedImage;
  File? _image; // Define the _image variable
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String? _imageUrl;
  double _rating = 0.0;

  List<String> categories = [];
  String selectedCategory = "";
  bool isTypingCategory = false;

  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    if (widget.courseId != null) {
      _loadCourseData();
    }
  }

  /// **Fetch Existing Categories from Firestore**
  Future<void> _fetchCategories() async {
    QuerySnapshot snapshot = await _firestore.collection('courses').get();
    Set<String> uniqueCategories = {};
    for (var doc in snapshot.docs) {
      uniqueCategories.add(doc['category']);
    }
    setState(() {
      categories = uniqueCategories.toList();
    });
  }

  /// **Load Existing Course Data for Editing**
  Future<void> _loadCourseData() async {
    DocumentSnapshot courseDoc =
        await _firestore.collection('courses').doc(widget.courseId).get();

    if (courseDoc.exists) {
      var courseData = courseDoc.data() as Map<String, dynamic>;

      setState(() {
        selectedCategory = courseData['category'] ?? '';
        _categoryController.text = selectedCategory;
        _nameController.text = courseData['name'] ?? '';
        _priceController.text = courseData['price']?.toString() ?? '';
        _offerPriceController.text = courseData['offerPrice']?.toString() ?? '';
        _rating = courseData['rating']?.toDouble() ?? 0.0;
        _imageUrl = courseData['imageUrl'];
      });
    }
  }

  /// **Pick Image from Gallery**
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? returnImage =
        await picker.pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    if (kIsWeb) {
      Uint8List imageBytes = await returnImage.readAsBytes();
      setState(() {
        selectedImage = imageBytes;
      });
    } else {
      setState(() {
        selectedImage = File(returnImage.path);
      });
    }
  }

  /// **Upload or Update Course**
  Future<void> _saveCourse() async {
    try {
      String uid = _auth.currentUser?.uid ?? "";
      String imageUrl = _imageUrl ?? "";
      String finalCategory = _categoryController.text.trim();

      if (finalCategory.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Please enter a category!")),
        );
        return;
      }
      final FirebaseStorage storage =
          FirebaseStorage.instanceFor(bucket: "gs://thinkflow");

      // Upload new image if selected
      if (selectedImage != null) {
        final ref = storage.ref().child(
            "course_images/${DateTime.now().millisecondsSinceEpoch}.jpg");
        UploadTask uploadTask = ref.putData(
            selectedImage!, SettableMetadata(contentType: 'image/jpg'));

        TaskSnapshot taskSnapshot = await uploadTask;
        imageUrl = await taskSnapshot.ref.getDownloadURL();
      }

      if (widget.courseId == null) {
        // **Create a new course**
        await _firestore.collection('courses').add({
          'uid': uid,
          'category': finalCategory,
          'name': _nameController.text,
          'price': _priceController.text,
          'offerPrice': _offerPriceController.text,
          'rating': _rating,
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Course Uploaded!")),
        );
      } else {
        // **Update existing course**
        await _firestore.collection('courses').doc(widget.courseId).update({
          'category': finalCategory,
          'name': _nameController.text,
          'price': _priceController.text,
          'offerPrice': _offerPriceController.text,
          'rating': _rating,
          'imageUrl': imageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Course Updated!")),
        );
      }

      // Close page after saving
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.courseId != null;
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: themeProvider.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(isEditing ? "Edit Course" : "Upload Course",
            style: TextStyle(color: themeProvider.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: _image == null && _imageUrl == null
                        ? themeProvider.textColor
                        : null,
                    borderRadius: BorderRadius.circular(10),
                    image: selectedImage != null
                        ? DecorationImage(
                            image: MemoryImage(selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : _imageUrl != null
                            ? DecorationImage(
                                image: NetworkImage(_imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                  ),
                  child: selectedImage == null && _imageUrl == null
                      ? Icon(Icons.add_a_photo,
                          size: 50, color: themeProvider.backgroundColor)
                      : null,
                ),
              ),
              SizedBox(height: 10),

              // Category Search Field
              _buildCategorySearchField(themeProvider),

              _buildTextField("Course Name", _nameController, themeProvider),
              _buildTextField("Price", _priceController, themeProvider,
                  isNumber: true),
              _buildTextField(
                  "Offer Price", _offerPriceController, themeProvider,
                  isNumber: true),
              SizedBox(height: 10),
              Text("Rate this Course",
                  style:
                      TextStyle(fontSize: 16, color: themeProvider.textColor)),
              _buildRatingBar(themeProvider),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  _saveCourse();
                },
                child: buildContinueButton(
                    isEditing ? "Update Course" : "Submit Course", context),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: themeProvider.backgroundColor,
    );
  }

  /// **Searchable Category Field**
  Widget _buildCategorySearchField(ThemeProvider themeProvider) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return Iterable<String>.empty();
        }
        return categories.where((category) => category
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (String selection) {
        _categoryController.text = selection;
      },
      fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
        controller.text = selectedCategory;

        return _buildTextField(
          "Course Category",
          controller,
          themeProvider,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
        );
      },
    );
  }

  Widget _buildTextField(
    String hintText,
    TextEditingController controller,
    ThemeProvider themeProvider, {
    bool isNumber = false,
    FocusNode? focusNode,
    VoidCallback? onEditingComplete,
    Function(String)? onChanged,
    int maxLines = 1,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
        onEditingComplete: onEditingComplete,
        onChanged: onChanged,
        decoration: InputDecoration(
          fillColor:
              themeProvider.isDarkMode ? Colors.grey[500] : Colors.grey[100],
          filled: true,
          labelText: hintText,
          labelStyle: TextStyle(color: themeProvider.textColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
          suffixIcon: suffixIcon != null
              ? IconButton(icon: Icon(suffixIcon), onPressed: onSuffixTap)
              : null,
        ),
      ),
    );
  }

  Widget _buildRatingBar(ThemeProvider themeProvider) {
    return Column(
      children: [
        RatingBar.builder(
          initialRating: _rating,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
          itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
          unratedColor:
              themeProvider.isDarkMode ? Colors.grey[700] : Colors.grey[400],
          onRatingUpdate: (rating) {
            setState(() {
              _rating = rating;
            });
          },
        ),
      ],
    );
  }
}
