import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/ThinkFlow/administration/admin.dart';
import 'package:thinkflow/ThinkFlow/course.dart';
import 'package:thinkflow/ThinkFlow/courseuplode.dart';
import 'package:thinkflow/ThinkFlow/llll.dart';
import 'package:thinkflow/ThinkFlow/login.dart';
import 'package:thinkflow/ThinkFlow/mentor.dart';
import 'package:thinkflow/ThinkFlow/mentprof.dart';
// import 'package:thinkflow/ThinkFlow/all_courses.dart'; // Add a page for displaying all courses

class HomePageScreen extends StatefulWidget {
  HomePageScreen({super.key});

  @override
  State<HomePageScreen> createState() => _HomePageScreenState();
}

class _HomePageScreenState extends State<HomePageScreen> {
  String selectedCategory = "All";
  late Future<List<String>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = _fetchCategories();
  }

  Future<List<String>> _fetchCategories() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('courses').get();

    Set<String> fetchedCategories = {};
    for (var doc in snapshot.docs) {
      String category = doc['category'] ?? 'Unknown';
      fetchedCategories.add(category);
    }
    return ["All", ...fetchedCategories];
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      drawer: _buildDrawer(context, themeProvider),
      appBar: _buildAppBar(themeProvider),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchBar(themeProvider),
              const SizedBox(height: 16),
              _buildBanner(themeProvider),
              const SizedBox(height: 16),
              _buildSectionTitle('Popular Courses', context, themeProvider),
              FutureBuilder<List<String>>(
                future: categoriesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData) return const SizedBox();
                  return _buildCategoryChips(snapshot.data!, themeProvider);
                },
              ),
              const SizedBox(height: 16),
              _buildCoursesList(themeProvider),
              const SizedBox(height: 16),
              _buildSectionTitle('Top Mentors', context, themeProvider),
              _buildMentorsList(themeProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, BuildContext context, ThemeProvider themeProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor),
        ),
        GestureDetector(
          onTap: () {
            FirebaseFirestore.instance
                .collection('users')
                .get()
                .then((snapshot) {
              if (snapshot.docs.isEmpty) {
                print('No users found!');
              } else {
                for (var doc in snapshot.docs) {
                  print(doc.data());
                }
              }
            });

            // Navigator.push(
            //   context,
            //   MaterialPageRoute(builder: (context) => AllCoursesPage()), // Navigate to all courses page
            // );
          },
          child: const Text(
            'SEE ALL',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildDrawer(BuildContext context, ThemeProvider themeProvider) {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    return Drawer(
      backgroundColor: themeProvider.backgroundColor,
      child: Column(
        children: [
          ListTile(
            title: Text("Become a Mentor",
                style: TextStyle(color: themeProvider.textColor)),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const MentorLoginPage()),
              );
            },
          ),
          ListTile(
            title: Text("Courses",
                style: TextStyle(color: themeProvider.textColor)),
            onTap: () {
              fetchUserData();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CourseUpload()),
              );
            },
          ),
          if (uid == "xq149ozD79fnsZcdOqY07u5F3lB2") // Check if UID matches
            ListTile(
              title: Text("Admin Page",
                  style: TextStyle(
                      color: themeProvider.textColor,
                      fontWeight: FontWeight.bold)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminPage()),
                );
              },
            ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(ThemeProvider themeProvider) {
    return AppBar(
      backgroundColor: themeProvider.backgroundColor.withOpacity(0.9),
      elevation: 0,
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
              backgroundColor: themeProvider.textColor, radius: 16),
        ),
      ],
      title: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, color: Colors.orange, size: 30),
          SizedBox(width: 5),
          Text(
            "ThinkFlow",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(ThemeProvider themeProvider) {
    return Container(
      decoration: BoxDecoration(
        color: themeProvider.textColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search for ...',
          hintStyle: TextStyle(color: themeProvider.textColor.withOpacity(0.6)),
          border: InputBorder.none,
          suffixIcon: const Icon(Icons.search, color: Colors.orange),
        ),
      ),
    );
  }

  Widget _buildBanner(ThemeProvider themeProvider) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: themeProvider.textColor.withOpacity(0.1),
      ),
    );
  }

  Widget _buildCategoryChips(
      List<String> categories, ThemeProvider themeProvider) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((category) {
          bool isSelected = category == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              selectedColor: Colors.orange,
              onSelected: (bool selected) {
                setState(() => selectedCategory = category);
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoursesList(ThemeProvider themeProvider) {
    return SizedBox(
      height: 250,
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

          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: courses.length,
            itemBuilder: (context, index) {
              var course = courses[index];
              return FutureBuilder(
                future: _calculateAverageRating(course.id),
                builder: (context, ratingSnapshot) {
                  double avgRating = ratingSnapshot.data ??
                      double.tryParse(course['rating'].toString()) ??
                      0.0;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseDetailPage(
                            courseId: course.id,
                          ),
                        ),
                      );
                    },
                    child: _buildCourseCard(
                      course['category'] ?? 'Unknown',
                      course['name'] ?? 'No Title',
                      double.tryParse(course['offerPrice'].toString()) ?? 0.0,
                      double.tryParse(course['price'].toString()) ?? 0.0,
                      avgRating,
                      course['imageUrl'] ?? '',
                      themeProvider,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<double> _calculateAverageRating(String courseId) async {
    DocumentSnapshot courseSnapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .get();

    double savedRating =
        double.tryParse(courseSnapshot['rating'].toString()) ?? 0.0;

    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('reviews')
        .where('courseId', isEqualTo: courseId)
        .get();

    double totalRating = 0;
    int count = 0;

    // ✅ Only include mentor rating if it's greater than 0
    if (savedRating > 0) {
      totalRating += savedRating;
      count++;
    }

    for (var doc in reviewsSnapshot.docs) {
      var reviewData = doc.data() as Map<String, dynamic>;
      if (reviewData.containsKey('rating') && reviewData['rating'] is num) {
        totalRating += (reviewData['rating'] as num).toDouble();
        count++;
      }
    }

    double avgRating = count > 0 ? totalRating / count : 0.0;

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(courseId)
        .update({
      'rating': avgRating,
    });

    return avgRating;
  }
}

Widget _buildPlaceholder(ThemeProvider themeProvider) {
  return Container(
    height: 100,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[300], // Placeholder color
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
    ),
    child: Center(
      child: Icon(Icons.image, color: Colors.grey[600], size: 40),
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
  print(imageUrl);
  print('[[[[[[[[[[[[[[=====]]]]]]]]]]]]]]');
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
          ),
          // child: Image.network(
          //   imageUrl!,
          //   height: 100,
          //   width: double.infinity,
          //   fit: BoxFit.cover,
          //   errorBuilder: (context, error, stackTrace) {
          //     return _buildPlaceholder(themeProvider);
          //   },
          // )
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
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

Widget _buildMentorsList(ThemeProvider themeProvider) {
  String currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  return SizedBox(
    height: 150, // Adjust height as needed
    child: StreamBuilder(
      stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
              child: Text('No mentors available',
                  style: TextStyle(color: themeProvider.textColor)));
        }
        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, // Adjust number of items per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var mentor = snapshot.data!.docs[index];
            String name = mentor['name'] ?? 'Unknown';
            String? imageUrl = mentor['profileimg'];
            String mentorId = mentor.id;

            return GestureDetector(
              onTap: () {
                if (currentUserId == mentorId) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MentorProfile(mentorId: mentorId),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MentorScreen(mentorId: mentorId),
                    ),
                  );
                }
              },
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40, // Adjust size
                    backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    name,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: themeProvider.textColor),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
}
