import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  ChatScreen({required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController _messageController = TextEditingController();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String receiverName = "Chat";
  String receiverProfile = "";

  @override
  void initState() {
    super.initState();
    _fetchReceiverDetails();
  }

  /// Fetch Receiver Details (Name & Profile Image)
  void _fetchReceiverDetails() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('mentors')
        .doc(widget.receiverId)
        .get();

    if (userDoc.exists) {
      setState(() {
        receiverName = userDoc['name'] ?? 'Chat';
        receiverProfile = userDoc['profileimg'] ?? '';
      });
    }
  }

  String getChatId() {
    List<String> ids = [currentUserId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: receiverProfile.isNotEmpty
                  ? NetworkImage(receiverProfile)
                  : null,
              backgroundColor: Colors.black,
              child: receiverProfile.isEmpty
                  ? Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            SizedBox(width: 8),
            Text(receiverName,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(getChatId())
                  .collection('chats')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("No messages yet."));
                }
                var messages = snapshot.data!.docs;
                String? lastMessageDate;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    var message = messages[index];
                    bool isMe = message['senderId'] == currentUserId;
                    Timestamp? timestamp = message['timestamp'];

                    DateTime messageTime =
                        timestamp != null ? timestamp.toDate() : DateTime.now();
                    String formattedDate = _formatDate(messageTime);

                    // Show date header at the top of the first message of the day
                    bool showDateHeader = lastMessageDate != formattedDate;
                    if (showDateHeader) {
                      lastMessageDate = formattedDate;
                    }

                    return Column(
                      children: [
                        if (showDateHeader) _buildDateHeader(formattedDate),
                        _buildMessage(message['text'], timestamp, isMe),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  /// **Build Each Chat Message**
  Widget _buildMessage(String text, Timestamp? timestamp, bool isMe) {
    DateTime messageTime =
        timestamp != null ? timestamp.toDate() : DateTime.now();
    String formattedTime =
        DateFormat('hh:mm a').format(messageTime); // ✅ AM/PM format

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isMe ? Colors.teal : Colors.grey[600],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(text, style: TextStyle(color: Colors.white)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12, left: 12),
            child: Text(
              formattedTime, // ✅ Only showing time, now in AM/PM
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// **Message Input Field**
  Widget _buildMessageInput() {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(24),
              ),
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Message',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          CircleAvatar(
            backgroundColor: Colors.orange,
            child: IconButton(
              icon: Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
            ),
          ),
        ],
      ),
    );
  }

  /// **Send Message to Firebase**
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    String chatId = getChatId();
    String messageText = _messageController.text.trim();

    _messageController.clear();

    await FirebaseFirestore.instance
        .collection('messages')
        .doc(chatId)
        .collection('chats')
        .add({
      'senderId': currentUserId,
      'receiverId': widget.receiverId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance.collection('chats').doc(chatId).set({
      'users': [currentUserId, widget.receiverId],
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _messageController.clear();
  }

  /// **Format Date for Messages**
  String _formatDate(DateTime dateTime) {
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));

    if (DateFormat('yyyyMMdd').format(dateTime) ==
        DateFormat('yyyyMMdd').format(now)) {
      return "Today";
    } else if (DateFormat('yyyyMMdd').format(dateTime) ==
        DateFormat('yyyyMMdd').format(yesterday)) {
      return "Yesterday";
    } else if (dateTime.isAfter(now.subtract(Duration(days: 7)))) {
      return DateFormat('EEEE').format(dateTime); // Monday, Tuesday, etc.
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime); // 12 Feb 2024
    }
  }

  /// **Date Header Widget**
  Widget _buildDateHeader(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[400],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
