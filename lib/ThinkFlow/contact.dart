import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:thinkflow/ThinkFlow/chat.dart';

class ContactScreen extends StatefulWidget {
  @override
  _ContactScreenState createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCFAF8),
      appBar: AppBar(
        backgroundColor: Color(0xFFFCFAF8),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Chats',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
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
                ? Expanded(child: _buildSearchResults())
                : Expanded(child: _buildChatList()),
          ],
        ),
      ),
    );
  }

  /// 🔹 Search Mentors (Only Followed Mentors)
  Widget _buildSearchResults() {
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

        var mentors = snapshot.data!.docs.where((mentor) {
          String name = (mentor['name'] ?? '').toString().toLowerCase();

          return name.contains(searchQuery);
        }).toList();

        return mentors.isEmpty
            ? Center(child: Text("No mentors found."))
            : ListView.builder(
                itemCount: mentors.length,
                itemBuilder: (context, index) {
                  var mentor = mentors[index];
                  return _buildChatTile(
                      mentor.id, mentor['name'], mentor['profileimg']);
                },
              );
      },
    );
  }

  /// 🔹 Show Recent Chats
  Widget _buildChatList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where('users', arrayContains: currentUserId)
          // .orderBy('lastMessageTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return Center(child: CircularProgressIndicator());

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
                  .collection('mentors')
                  .doc(otherUserId)
                  .get(),
              builder: (context, mentorSnapshot) {
                if (!mentorSnapshot.hasData || !mentorSnapshot.data!.exists)
                  return SizedBox();

                var mentor = mentorSnapshot.data!;
                String name = mentor['name'] ?? 'Unknown';
                String profileImg = mentor['profileimg'] ?? '';

                return _buildChatTile(otherUserId, name, profileImg);
              },
            );
          },
        );
      },
    );
  }

  /// 🔹 Chat Tile UI
  Widget _buildChatTile(String mentorId, String? name, String? profileImg) {
    return ListTile(
      leading: CircleAvatar(
        backgroundImage: profileImg != null && profileImg.isNotEmpty
            ? NetworkImage(profileImg)
            : null,
        backgroundColor: Colors.black,
        child: profileImg == null || profileImg.isEmpty
            ? Icon(Icons.person,
                color: Colors.white) // Default icon if no image
            : null,
      ),
      title: Text(name ?? 'Unknown',
          style: TextStyle(fontWeight: FontWeight.bold)),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ChatScreen(receiverId: mentorId)),
        );
      },
    );
  }
}
