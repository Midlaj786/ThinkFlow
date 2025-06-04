import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatelessWidget {
  final currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        title: Text(
          "Notifications",
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: IconThemeData(color: themeProvider.textColor),
      
        elevation: 0,
      ),
      backgroundColor: themeProvider.backgroundColor,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser!.uid)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: themeProvider.textColor));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No notifications yet.",
                  style: TextStyle(color: themeProvider.textColor)),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final data = notifications[index].data() as Map<String, dynamic>;
              final time = (data['timestamp'] as Timestamp).toDate();
              final formattedTime = DateFormat('MMM dd, hh:mm a').format(time);

              return Card(
                color: themeProvider.backgroundColor.withOpacity(0.05),
                child: ListTile(
                  leading: Icon(Icons.notifications_active, color: themeProvider.textColor),
                  title: Text(
                    "${data['mentorName']} added a new course!",
                    style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${data['courseTitle']} • $formattedTime",
                    style: TextStyle(color: themeProvider.textColor.withOpacity(0.7)),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: themeProvider.textColor),
                  onTap: () {
                    // Navigate to course details using courseId or similar
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
