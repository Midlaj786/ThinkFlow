import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';

class AdminCoursesPage extends StatefulWidget {
  @override
  _AdminCoursesPageState createState() => _AdminCoursesPageState();
}

class _AdminCoursesPageState extends State<AdminCoursesPage> {
  String selectedCategory = "All";
  List<String> categories = ["All"];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('courses').get();
    Set<String> uniqueCategories = {};
    for (var doc in snapshot.docs) {
      uniqueCategories.add(doc['category']);
    }
    setState(() {
      categories.addAll(uniqueCategories.toList());
    });
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
        title: Text("Manage Courses",
            style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilterDropdown(themeProvider),
          Expanded(child: _buildCourseList(themeProvider)),
        ],
      ),
    );
  }

  /// **Category Filter Dropdown**
  Widget _buildFilterDropdown(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedCategory,
        items: categories.map((String category) {
          return DropdownMenuItem<String>(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedCategory = value!;
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: "Filter by Category",
        ),
      ),
    );
  }

  /// **Courses ListView**
  Widget _buildCourseList(ThemeProvider themeProvider) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('courses').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var courses = snapshot.data!.docs.where((doc) {
          return selectedCategory == "All" || doc['category'] == selectedCategory;
        }).toList();

        if (courses.isEmpty) {
          return Center(child: Text("No courses available."));
        }

        return ListView.builder(
          itemCount: courses.length,
          itemBuilder: (context, index) {
            var course = courses[index].data();
            return Card(
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: course['imageUrl'] != null
                    ? Image.network(course['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.book, size: 40),
                title: Text(course['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Category: ${course['category']}"),
                trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.textColor),
                onTap: () {
                  // Navigate to course details if needed
                },
              ),
            );
          },
        );
      },
    );
  }
}
