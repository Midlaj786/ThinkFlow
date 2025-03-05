import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class ReviewPage extends StatefulWidget {
    final String courseId;
  
  ReviewPage({required this.courseId});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  TextEditingController _reviewController = TextEditingController();
   double _rating = 0.0;
  String courseName = "";
  String category = "";
  String? imageUrl;
   @override
  void initState() {
    super.initState();
    _fetchCourseData();
  }
  Future<void> _fetchCourseData() async {
    var courseDoc = await FirebaseFirestore.instance.collection("courses").doc(widget.courseId).get();
    if (courseDoc.exists) {
      setState(() {
        courseName = courseDoc["name"];
        category = courseDoc["category"];
        imageUrl = courseDoc["imageUrl"];
      });
    }
  }
   Future<Map<String, dynamic>?> _getUserDetails() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>?;
      }
    }
    return null;
  }
 Future<void> _submitReview() async {
    String reviewText = _reviewController.text.trim();
    if (reviewText.isNotEmpty) {
      Map<String, dynamic>? userDetails = await _getUserDetails();
      if (userDetails != null) {
        await FirebaseFirestore.instance.collection('reviews').add({
          'courseId': widget.courseId,
          'courseName': courseName,
          'category': category,
          'userName': userDetails['name'] ?? 'Anonymous',
          'userProfile': userDetails['profileimg'] ?? '',
          'review': reviewText,
          'rating': _rating,
          'timestamp': FieldValue.serverTimestamp() ,
          'likes': 0,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Review submitted successfully")),
        );
        _reviewController.clear();
        setState(() {
          _rating = 0.0;
        });
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Write a Review",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade300, blurRadius: 5)
                ],
              ),
              padding: EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: imageUrl != null ? Colors.transparent : Colors.black,
                      borderRadius: BorderRadius.circular(8),
                      image: imageUrl != null
                          ? DecorationImage(
                              image: NetworkImage(imageUrl!),
                              fit: BoxFit.cover)
                          : null,
                    ),
                  ),
                  SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(category,
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold)),
                      SizedBox(height: 5),
                      Text(courseName,
                          style: TextStyle(fontWeight: FontWeight.w500)),
                    ],
                  )
                ],
              ),
            ),
             SizedBox(height: 20),
            Text("Rate this Course", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 20),
            Text("Write your Review", style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            TextFormField(
              controller: _reviewController,
              maxLength: 500,
              maxLines: 5,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            Center(child:GestureDetector(onTap: _submitReview,
              child: buildContinueButton("Submit", context)))
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }
}
