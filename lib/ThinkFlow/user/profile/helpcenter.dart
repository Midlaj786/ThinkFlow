import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart'; // adjust the path if needed

class HelpCenterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        title: Text('Help Center', style: TextStyle(color: themeProvider.textColor)),
        backgroundColor: themeProvider.backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: themeProvider.textColor),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Frequently Asked Questions',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildFAQTile(
            themeProvider,
            question: 'How do I reset my password?',
            answer: 'Go to the login page, tap "Forgot Password", and follow the instructions.',
          ),
          _buildFAQTile(
            themeProvider,
            question: 'How can I contact a mentor?',
            answer: 'Go to a mentor’s profile and tap the "Message" button (if you follow them).',
          ),
          _buildFAQTile(
            themeProvider,
            question: 'How do I buy a course?',
            answer: 'Tap on any course, then press the "Buy Now" button and complete payment.',
          ),
          const SizedBox(height: 24),
          Text(
            'Need More Help?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: themeProvider.textColor,
            ),
          ),
          const SizedBox(height: 12),
          ListTile(
            leading: Icon(Icons.email, color: themeProvider.textColor),
            title: Text('Email Us', style: TextStyle(color: themeProvider.textColor)),
            subtitle: Text('support@thinkflow.com', style: TextStyle(color: themeProvider.textColor.withOpacity(0.7))),
            onTap: () {
              // open mail app or handle action
            },
          ),
          ListTile(
            leading: Icon(Icons.chat_bubble_outline, color: themeProvider.textColor),
            title: Text('Live Chat', style: TextStyle(color: themeProvider.textColor)),
            subtitle: Text('Chat with our support team', style: TextStyle(color: themeProvider.textColor.withOpacity(0.7))),
            onTap: () {
              // open in-app chat or link to external chat
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFAQTile(ThemeProvider themeProvider, {required String question, required String answer}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        collapsedIconColor: themeProvider.textColor,
        iconColor: themeProvider.textColor,
        title: Text(
          question,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: themeProvider.textColor,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Text(answer, style: TextStyle(color: themeProvider.textColor)),
          )
        ],
      ),
    );
  }
}
