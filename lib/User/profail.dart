import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/ThinkFlow/bottomNav.dart';
import 'package:thinkflow/ThinkFlow/terms.dart';
import 'package:thinkflow/User/editprofile.dart';
import 'package:thinkflow/User/home.dart';
import 'package:thinkflow/ThinkFlow/widgets.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Loading...';
  String _email = 'Loading...';
  String _profileImage = '';

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    if (userDoc.exists) {
      setState(() {
        _name = userDoc['name'];
        _email = userDoc['email'];
        _profileImage = userDoc['profileimg'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: themeProvider.textColor,
            ),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (context) => MainScreen()))),
        title:
            Text("Profile", style: TextStyle(color: themeProvider.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(6.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: () {
                    showImageDialog(context, _profileImage);
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                    backgroundImage: _profileImage.isNotEmpty
                        ? NetworkImage(_profileImage)
                        : null,
                    child: _profileImage.isEmpty
                        ? Icon(Icons.person,
                            size: 50, color: themeProvider.backgroundColor)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(_name,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: themeProvider.textColor)),
              Text(_email, style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              _buildProfileOption(
                Icons.edit,
                "Edit Profile",
                themeProvider,
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilePage()));
                },
              ),
              _buildProfileOption(
                  Icons.notifications, "Notifications", themeProvider),
              _buildProfileOption(Icons.security, "Security", themeProvider),
              _buildProfileOption(Icons.language, "Language", themeProvider,
                  trailingText: "English (US)"),
              _buildProfileOption(
                Icons.dark_mode,
                "Dark Mode",
                themeProvider,
                trailingText: themeProvider.isDarkMode ? "Disable" : "Enable",
                onTap: () => _showDarkModeDialog(context, themeProvider),
              ),
              _buildProfileOption(
                Icons.policy,
                "Terms & Conditions",
                themeProvider,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => TermsAndConditionsPage()),
                  );
                },
              ),
              _buildProfileOption(
                  Icons.help_center, "Help Center", themeProvider),
              _buildProfileOption(Icons.group, "Invite Friends", themeProvider),
              _buildProfileOption(Icons.logout, "Logout", themeProvider,
                  isLogout: true, onTap: () => _showLogoutDialog(context)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.backgroundColor,
        title: Text(
          "Logout",
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          "Are you sure you want to logout?",
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("No", style: TextStyle(color: themeProvider.textColor)),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(
      IconData icon, String title, ThemeProvider themeProvider,
      {String? trailingText, bool isLogout = false, VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading:
            Icon(icon, color: isLogout ? Colors.red : themeProvider.textColor),
        title: Text(title,
            style: TextStyle(fontSize: 16, color: themeProvider.textColor)),
        trailing: trailingText != null
            ? Text(trailingText, style: TextStyle(color: Colors.blue))
            : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap ?? () {},
      ),
    );
  }

  void _showDarkModeDialog(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.backgroundColor,
        title: Text(
          "Dark Mode",
          style: TextStyle(color: themeProvider.textColor),
        ),
        content: Text(
          themeProvider.isDarkMode ? "Disable Dark Mode?" : "Enable Dark Mode?",
          style: TextStyle(color: themeProvider.textColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel",
                style: TextStyle(color: themeProvider.textColor)),
          ),
          TextButton(
            onPressed: () {
              themeProvider.toggleTheme();
              Navigator.pop(context);
            },
            child: Text(themeProvider.isDarkMode ? "Disable" : "Enable",
                style: TextStyle(color: themeProvider.textColor)),
          ),
        ],
      ),
    );
  }
}
