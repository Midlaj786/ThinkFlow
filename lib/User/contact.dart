import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:thinkflow/User/chat.dart';

class ContactScreen extends StatefulWidget {
  ContactScreen({super.key});

  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

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
        title: Text('Chats',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: themeProvider.textColor)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 🔹 Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Search for mentors...',
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search, color: Colors.orange),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase();
                  });
                },
              ),
            ),
            SizedBox(height: 16),

            // 🔹 Show Searched Mentors or Recent Chats
            searchQuery.isNotEmpty
                ? Expanded(child: _buildSearchResults(themeProvider))
                : Expanded(child: _buildChatList(themeProvider)),
          ],
        ),
      ),
    );
  }

  /// 🔹 Search Mentors (Only Followed Mentors)
  Widget _buildSearchResults(ThemeProvider themeProvider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('mentors')
          .where('followers', arrayContains: currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No mentors found."));
        }

        var mentors = snapshot.data!.docs.where((user) {
          String name = (user['name'] ?? '').toString().toLowerCase();

          return name.contains(searchQuery);
        }).toList();

        return mentors.isEmpty
            ? Center(child: Text("No mentors found."))
            : ListView.builder(
                itemCount: mentors.length,
                itemBuilder: (context, index) {
                  var user = mentors[index];
                  return _buildChatTile(
                      user.id, user['name'], user['profileimg'], '', null, 0, themeProvider);
                },
              );
      },
    );
  }

  /// 🔹 Show Recent Chats
Widget _buildChatList(ThemeProvider themeProvider) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          // .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text("No chats yet."));
        }

        var chats = snapshot.data!.docs;
        return ListView.builder(
          itemCount: chats.length,
          itemBuilder: (context, index) {
            var chat = chats[index];
            List<dynamic> users = chat['users'] ?? [];
            String? otherUserId = users.firstWhere((id) => id != currentUserId,
                orElse: () => null);

            if (otherUserId == null) return SizedBox();
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(otherUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                  return SizedBox();
                }

                var user = userSnapshot.data!;
                String name = user['name'] ?? 'Unknown';
                String profileImg = user['profileimg'] ?? '';
                String lastMessage = chat['lastMessage'] ?? '';
                Timestamp? lastMessageTime = chat['lastMessageTime'];
                
                // Check if the unreadCounts field exists and access it safely
                int unreadCount = 0;
                if (chat['unreadCounts'] != null && chat['unreadCounts'][currentUserId] != null) {
                  unreadCount = chat['unreadCounts'][currentUserId] ?? 0;
                }

                return _buildChatTile(
                  otherUserId,
                  name,
                  profileImg,
                  lastMessage,
                  lastMessageTime,
                  unreadCount,
                  themeProvider,
                );
              },
            );
          },
        );
      },
    );
  }


  /// 🔹 Chat Tile UI
  Widget _buildChatTile( String mentorId,
  String? name,
  String? profileImg,
  String lastMessage,
  Timestamp? lastMessageTime,
  int unreadCount,
  ThemeProvider themeProvider,) {
    return ListTile(
  leading: Stack(
    children: [
      CircleAvatar(
        backgroundImage: profileImg != null && profileImg.isNotEmpty
            ? NetworkImage(profileImg)
            : null,
        backgroundColor: themeProvider.textColor,
        child: profileImg == null || profileImg.isEmpty
            ? Icon(Icons.person, color: themeProvider.backgroundColor)
            : null,
      ),
      if (unreadCount > 0)
        Positioned(
          right: 0,
          child: Container(
            padding: EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
            child: Text(
              unreadCount.toString(),
              style: TextStyle(color: Colors.white, fontSize: 10),
            ),
          ),
        ),
    ],
  ),
  title: Text(
    name ?? 'Unknown',
    style: TextStyle(fontWeight: FontWeight.bold, color: themeProvider.textColor),
  ),
  subtitle: Text(
    lastMessage,
    maxLines: 1,
    overflow: TextOverflow.ellipsis,
    style: TextStyle(color: themeProvider.textColor.withOpacity(0.6)),
  ),
  trailing: Text(
    lastMessageTime != null
        ? TimeOfDay.fromDateTime(lastMessageTime.toDate()).format(context)
        : '',
    style: TextStyle(color: themeProvider.textColor.withOpacity(0.6), fontSize: 12),
  ),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(receiverId: mentorId),
      ),
    );
  },
);

  }
}
