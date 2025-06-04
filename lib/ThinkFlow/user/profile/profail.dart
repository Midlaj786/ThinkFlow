import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Mentor/registration.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:thinkflow/thinkflow/user/profile/editprofile.dart';
import 'package:thinkflow/thinkflow/user/profile/helpcenter.dart';
import 'package:thinkflow/thinkflow/user/profile/notification.dart';
import 'package:thinkflow/thinkflow/user/profile/securitypage.dart';
import 'package:thinkflow/thinkflow/user/profile/terms.dart';
import 'package:thinkflow/thinkflow/user/widgets/bottomNav.dart';
import 'package:thinkflow/thinkflow/user/widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _name = 'Loading...';
  String _email = 'Loading...';
  String _profileImage = '';
  bool _isMentor = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print("No user logged in.");
      return;
    }

    try {
      DocumentSnapshot mentorDoc = await FirebaseFirestore.instance
          .collection('mentors')
          .doc(user.uid)
          .get();

      if (mentorDoc.exists && mentorDoc.data() != null) {
        final data = mentorDoc.data() as Map<String, dynamic>;
        setState(() {
          _isMentor = true;
          _name = data['name'] ?? 'No name';
          _profileImage = data['profileimg'] ?? '';
          _email = data['email'] ?? 'No email';
          _isLoading = false;
        });
        print("Mentor data loaded.");
      } else {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          setState(() {
            _isMentor = false;
            _name = data['name'] ?? 'No name';
            _profileImage = data['profileimg'] ?? '';
            _email = data['email'] ?? 'No email';
            _isLoading = false;
          });
          print("User data loaded.");
        } else {
          print("No user or mentor data found.");
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _isLoading = false;
      });
    }
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const MainScreen()));
            }),
        title: Text("Profile", style: TextStyle(color: themeProvider.textColor)),
        
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(6.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          showImageDialog(context, _profileImage);
                        },
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black,
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
                    const SizedBox(height: 10),
                    Text(_name,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: themeProvider.textColor)),
                    Text(_email, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 20),
                    _buildProfileOption(Icons.edit, "Edit Profile", themeProvider,
                        onTap: () {
                      if (_isMentor) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MentorLoginPage()),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfilePage()),
                        );
                      }
                    }),
                    _buildProfileOption(Icons.notifications, "Notifications",
                        themeProvider, onTap: () {
                          Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>NotificationPage()),
                      );
                        }),
                    _buildProfileOption(Icons.security, "Security", themeProvider,onTap:(){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SecurityPage()),
                      );
                    }),
                    _buildProfileOption(Icons.language, "Language", themeProvider,
                        trailingText: "English (US)"),
                    _buildProfileOption(
                      Icons.dark_mode,
                      "Dark Mode",
                      themeProvider,
                      trailingText:
                          themeProvider.isDarkMode ? "Disable" : "Enable",
                      onTap: () => _showDarkModeDialog(context, themeProvider),
                    ),
                    _buildProfileOption(Icons.policy, "Terms & Conditions",
                        themeProvider, onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsAndConditionsPage()),
                      );
                    }),
                    _buildProfileOption(
                        Icons.help_center, "Help Center", themeProvider,onTap: () {
                       Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => HelpCenterPage()),
                      );
                        },),
                    _buildProfileOption(
                        Icons.group, "Invite Friends", themeProvider),
                    _buildProfileOption(Icons.logout, "Logout", themeProvider,
                        isLogout: true,
                        onTap: () => _showLogoutDialog(context)),
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
        title: Text("Logout", style: TextStyle(color: themeProvider.textColor)),
        content: Text("Are you sure you want to logout?",
            style: TextStyle(color: themeProvider.textColor)),
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
            child: const Text("Yes", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title,
      ThemeProvider themeProvider,
      {String? trailingText, bool isLogout = false, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon,
            color: isLogout ? Colors.red : themeProvider.textColor),
        title: Text(title,
            style: TextStyle(fontSize: 16, color: themeProvider.textColor)),
        trailing: trailingText != null
            ? Text(trailingText, style: const TextStyle(color: Colors.blue))
            : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: onTap ?? () {},
      ),
    );
  }

  void _showDarkModeDialog(
      BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: themeProvider.backgroundColor,
        title: Text("Dark Mode",
            style: TextStyle(color: themeProvider.textColor)),
        content: Text(
            themeProvider.isDarkMode
                ? "Disable Dark Mode?"
                : "Enable Dark Mode?",
            style: TextStyle(color: themeProvider.textColor)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                Text("Cancel", style: TextStyle(color: themeProvider.textColor)),
          ),
          TextButton(
            onPressed: () {
              themeProvider.toggleTheme();
              Navigator.pop(context);
            },
            child: Text(
              themeProvider.isDarkMode ? "Disable" : "Enable",
              style: TextStyle(color: themeProvider.textColor),
            ),
          ),
        ],
      ),
    );
  }
}
