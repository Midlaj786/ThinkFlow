import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';

import 'package:thinkflow/ThinkFlow/course.dart'; // Adjust path if needed

class CourseSearch extends StatefulWidget {
  @override
  _CourseSearchState createState() => _CourseSearchState();
}

class _CourseSearchState extends State<CourseSearch> {
  String selectedCategory = "All";
  List<String> categories = ["All"];
  TextEditingController _searchController = TextEditingController();
List<String> _suggestions = [];
List<DocumentSnapshot> _allCourses = [];


  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

 Future<void> _fetchCategories() async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('courses').get();

  Set<String> uniqueCategories = {};
  for (var doc in snapshot.docs) {
    uniqueCategories.add(doc['category']);
  }

  setState(() {
    categories.addAll(uniqueCategories.toList());
    _allCourses = snapshot.docs; // store for suggestions
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
        title: Text(
          "Search courses",
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(themeProvider),
          _buildCategoryChips(),
          Expanded(child: _buildCoursesList(themeProvider)),
        ],
      ),
    );
  }
  void _updateSuggestions(String query) {
  if (query.isEmpty) {
    setState(() => _suggestions = []);
    return;
  }

  final lowerQuery = query.toLowerCase();

  final matchedCourses = _allCourses
      .where((doc) => doc['name'].toLowerCase().contains(lowerQuery))
      .map((doc) => doc['name'])
      .toList();

  final matchedCategories = categories
      .where((cat) => cat.toLowerCase().contains(lowerQuery))
      .toList();

  setState(() {
    _suggestions = [...matchedCourses, ...matchedCategories];
  });
}


 Widget _buildSearchBar(ThemeProvider themeProvider) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: _updateSuggestions,
          decoration: InputDecoration(
            hintText: "Search courses or categories...",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_suggestions.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _suggestions[index];

                return ListTile(
                  title: Text(suggestion),
                  onTap: () {
                    // Check if it's a category or course name
                    if (categories.contains(suggestion)) {
                      setState(() {
                        selectedCategory = suggestion;
                        _suggestions.clear();
                        _searchController.clear();
                      });
                    } else {
                      final courseDoc = _allCourses.firstWhere(
                          (doc) => doc['name'] == suggestion,
                          orElse: () => throw Exception('Course not found'));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CourseDetailPage(courseId: courseDoc.id),
                        ),
                      );
                    }
                  },
                );
              },
            ),
          )
      ],
    ),
  );
}


  Widget _buildCategoryChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: categories.map((category) {
          bool isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedCategory = category;
                });
              },
              selectedColor: Colors.green,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoursesList(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('courses').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          var courses = snapshot.data!.docs
              .where((course) =>
                  selectedCategory == "All" ||
                  course['category'] == selectedCategory)
              .toList();
          if (courses.isEmpty) {
            return const Center(child: Text("No courses found"));
          }

          return GridView.builder(
            itemCount: courses.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) {
              var course = courses[index];
              double rating =
                  double.tryParse(course['rating'].toString()) ?? 0.0;
              double offerPrice =
                  double.tryParse(course['offerPrice'].toString()) ?? 0.0;
              double price = double.tryParse(course['price'].toString()) ?? 0.0;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          CourseDetailPage(courseId: course.id),
                    ),
                  );
                },
                child: _buildCourseCard(
                  course['category'] ?? 'Unknown',
                  course['name'] ?? 'No Title',
                  offerPrice,
                  price,
                  rating,
                  course['imageUrl'] ?? '',
                  themeProvider,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCourseCard(
      String category,
      String name,
      double offerPrice,
      double price,
      double rating,
      String? imageUrl,
      ThemeProvider themeProvider) {
    return Container(
      width: 180,
      
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          const BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Image.network(
              imageUrl!,
              height: 100,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 100,
                  width: double.infinity,
                  color: themeProvider.isDarkMode
                      ? Colors.grey[200]
                      : Colors.grey[900],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category,
                    style: const TextStyle(color: Colors.orange, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹${offerPrice.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.green),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${price.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 16),
                    const SizedBox(width: 4),
                    Text(rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
