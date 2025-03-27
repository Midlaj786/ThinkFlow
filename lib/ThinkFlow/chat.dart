import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:thinkflow/ThinkFlow/Theme.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  ChatScreen({super.key, required this.receiverId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  late IO.Socket socket;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  String receiverName = "Chat";
  String receiverProfile = "";

  @override
  void initState() {
    super.initState();
    _fetchReceiverDetails();
    _initializeSocket();
  }

  void _initializeSocket() {
    socket = IO.io("https://your-socket-server.com", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.connect();

    socket.onConnect((_) {
      print("Connected to Socket.IO Server");
      socket.emit("join_chat", getChatId());
    });

    socket.on("receive_message", (data) {
      if (mounted) {
        setState(() {}); // Update UI on new message
      }
    });

    socket.onDisconnect((_) {
      print("Disconnected from Socket.IO Server");
    });
  }

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
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: receiverProfile.isNotEmpty
                  ? NetworkImage(receiverProfile)
                  : null,
              backgroundColor: themeProvider.textColor,
              child: receiverProfile.isEmpty
                  ? Icon(Icons.person, color: themeProvider.backgroundColor)
                  : null,
            ),
            SizedBox(width: 8),
            Text(receiverName,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.textColor)),
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

  Widget _buildMessage(String text, Timestamp? timestamp, bool isMe) {
    DateTime messageTime =
        timestamp != null ? timestamp.toDate() : DateTime.now();
    String formattedTime = DateFormat('hh:mm a').format(messageTime);

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
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: isMe ? Radius.circular(12) : Radius.circular(0),
                bottomRight: isMe ? Radius.circular(0) : Radius.circular(12),
              ),
            ),
            child: Text("$text   ", style: TextStyle(color: Colors.white)),
          ),
          Padding(
            padding: EdgeInsets.only(right: 12, left: 12),
            child: Text(
              formattedTime,
              style: TextStyle(color: Colors.grey, fontSize: 10),
            ),
          ),
        ],
      ),
    );
  }

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

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    String messageText = _messageController.text.trim();
    _messageController.clear();

    socket.emit("send_message", {
      "chatId": getChatId(),
      "senderId": currentUserId,
      "receiverId": widget.receiverId,
      "text": messageText,
      "timestamp": DateTime.now().millisecondsSinceEpoch,
    });

    FirebaseFirestore.instance
        .collection('messages')
        .doc(getChatId())
        .collection('chats')
        .add({
      'senderId': currentUserId,
      'receiverId': widget.receiverId,
      'text': messageText,
      'timestamp': FieldValue.serverTimestamp(),
    });

    FirebaseFirestore.instance.collection('chats').doc(getChatId()).set({
      'users': [currentUserId, widget.receiverId],
      'lastMessage': messageText,
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

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
      return DateFormat('EEEE').format(dateTime);
    } else {
      return DateFormat('dd MMM yyyy').format(dateTime);
    }
  }

  Widget _buildDateHeader(String date) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 1, horizontal: 7),
          decoration: BoxDecoration(
            color: Colors.grey[600],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    socket.disconnect();
    super.dispose();
  }
}
