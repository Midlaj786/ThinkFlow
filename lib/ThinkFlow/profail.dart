import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade300,
                      child: Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white,
                        child: Icon(Icons.camera_alt, color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10),
              Text("Muhammed Midlaj",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("hernandex.redial@gmail.ac.in",
                  style: TextStyle(color: Colors.grey)),
              SizedBox(height: 20),
              _buildProfileOption(Icons.edit, "Edit Profile"),
              _buildProfileOption(Icons.notifications, "Notifications"),
              _buildProfileOption(Icons.security, "Security"),
              _buildProfileOption(Icons.language, "Language",
                  trailingText: "English (US)"),
              _buildProfileOption(Icons.dark_mode, "Dark Mode"),
              _buildProfileOption(Icons.policy, "Terms & Conditions"),
              _buildProfileOption(Icons.help_center, "Help Center"),
              _buildProfileOption(Icons.group, "Invite Friends"),
              _buildProfileOption(Icons.logout, "Logout", isLogout: true),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildProfileOption(IconData icon, String title,
      {String? trailingText, bool isLogout = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: isLogout ? Colors.red : Colors.black),
        title: Text(title, style: TextStyle(fontSize: 16)),
        trailing: trailingText != null
            ? Text(trailingText, style: TextStyle(color: Colors.blue))
            : Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
