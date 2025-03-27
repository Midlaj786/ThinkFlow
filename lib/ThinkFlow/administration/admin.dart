import 'package:flutter/material.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/administration/admincourse.dart';
import 'package:thinkflow/ThinkFlow/administration/adminmentor.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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
        title: Text("Admin Dashboard",
            style: TextStyle(
                color: themeProvider.textColor, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildOptionTile(
              context,
              title: "Manage Courses",
              icon: Icons.book,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminCoursesPage()));
              },
            ),
            _buildOptionTile(
              context,
              title: "Manage Mentors",
              icon: Icons.person,
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AdminMentorsPage()));
              },
            ),
          ],
        ),
      ),
    );
  }

  /// **Reusable ListTile Option**
  Widget _buildOptionTile(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onTap}) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Card(
      color: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.orange, size: 30),
        title: Text(title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.textColor),
        onTap: onTap,
      ),
    );
  }
}
