import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:thinkflow/ThinkFlow/chat.dart';
Widget buildContinueButton(String text, BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 0.7,
    height: 50,
    decoration: BoxDecoration(
      color: Colors.orange,
      borderRadius: BorderRadius.circular(30),
      boxShadow: [
        BoxShadow(
          color: Colors.orange.withOpacity(0.5),
          blurRadius: 8,
        ),
      ],
    ),
    child: Stack(
      alignment: Alignment.centerRight,
      children: [
        Center(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        Positioned(
          right: 10,
          child: Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.arrow_forward,
              color: Colors.orange,
            ),
          ),
        ),
      ],
    ),
  );
}
String timeAgo(Timestamp? timestamp) {
  if (timestamp == null) return "Unknown";

  DateTime postTime = timestamp.toDate();
  Duration diff = DateTime.now().difference(postTime);

  if (diff.inSeconds < 60) {
    return "${diff.inSeconds} seconds ago";
  } else if (diff.inMinutes < 60) {
    return "${diff.inMinutes} minutes ago";
  } else if (diff.inHours < 24) {
    return "${diff.inHours} hours ago";
  } else if (diff.inDays < 7) {
    return "${diff.inDays} days ago";
  } else {
    return DateFormat('dd MMM yyyy').format(postTime); // Show full date if over a week
  }
}
void startChat(BuildContext context, String receiverId) async {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Check if a chat already exists
  QuerySnapshot existingChat = await FirebaseFirestore.instance
      .collection('messages')
      .where('users', arrayContains: currentUserId)
      .get();

  String? chatId;

  for (var doc in existingChat.docs) {
    List users = doc['users'];
    if (users.contains(receiverId)) {
      chatId = doc.id;
      break;
    }
  }

  if (chatId == null) {
    // ✅ Create new chat document if it doesn't exist
    DocumentReference chatRef = FirebaseFirestore.instance.collection('messages').doc();
    chatId = chatRef.id;
    await chatRef.set({
      'users': [currentUserId, receiverId],
      'lastMessage': '',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // ✅ Navigate to chat screen
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ChatScreen(receiverId: receiverId,),
    ),
  );
}


 // ListTile(
                                    //   leading: CircleAvatar(
                                    //     backgroundImage:
                                    //         review['userProfile'] != null &&
                                    //                 review['userProfile']
                                    //                     .isNotEmpty
                                    //             ? NetworkImage(
                                    //                 review['userProfile'])
                                    //             : null,
                                    //     backgroundColor: Colors.grey,
                                    //   ),
                                    //   title: Text(
                                    //       review['userName'] ?? "Anonymous"),
                                    //   subtitle: Column(
                                    //     crossAxisAlignment:
                                    //         CrossAxisAlignment.start,
                                    //     children: [
                                    //       Text(review['review']),
                                    //       Text("Rating: ${review['rating']}")
                                    //     ],
                                    //   ),
                                    //   trailing: Row(
                                    //     mainAxisSize: MainAxisSize.min,
                                    //     children: [
                                    //       IconButton(
                                    //         icon: Icon(
                                    //           Icons.favorite,
                                    //           color: isLiked
                                    //               ? Colors.red
                                    //               : Colors.grey,
                                    //         ),
                                    //         onPressed: () {
                                    //           // FirebaseFirestore.instance
                                    //           //     .collection('reviews')
                                    //           //     .doc(review.id)
                                    //           //     .update({
                                    //           //   'likes':
                                    //           //       (review['likes'] ?? 0) + 1,
                                    //           // });
                                    //         },
                                    //       ),
                                    //       // Text("${review['likes'] ?? 0}"),
                                    //     ],
                                    //   ),
                                    // );



                                    // 11111111111111111111111111111111111111111


                                    // Padding(
                                    //   padding: EdgeInsets.symmetric(vertical: 8),
                                    //   child: Row(
                                    //     crossAxisAlignment: CrossAxisAlignment.start,
                                    //     children: [
                                    //       CircleAvatar(
                                    //         radius: 24,
                                    //          backgroundImage: review['userProfile'] != null && review['userProfile'].isNotEmpty
                                    //                                         ? NetworkImage(review['userProfile'])
                                    //                                         : null,
                                    //                                     backgroundColor: Colors.grey,
                                    //       ),
                                    //       SizedBox(width: 12),
                                    //       Expanded(
                                    //         child: Column(
                                    //           crossAxisAlignment: CrossAxisAlignment.start,
                                    //           children: [
                                    //             Row(
                                    //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    //               children: [
                                    //                 Text(review["userName"], style: TextStyle(fontWeight: FontWeight.bold)),
                                    //                 Container(
                                    //                   padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    //                   decoration: BoxDecoration(
                                    //                     color: Colors.orange,
                                    //                     borderRadius: BorderRadius.circular(8),
                                    //                   ),
                                    //                   child: Row(
                                    //                     children: [
                                    //                       Icon(Icons.star, size: 14, color: Colors.white),
                                    //                       Text(review['rating'].toString(),
                                    //                           style:
                                    //                               TextStyle(color: Colors.white, fontSize: 12)),
                                    //                     ],
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //             SizedBox(height: 4),
                                    //             Text(review['review'], style: TextStyle(color: Colors.grey[700])),
                                    //             SizedBox(height: 8),
                                    //             Row(
                                    //               children: [
                                    //                 IconButton(icon:  Icon(Icons.favorite, color: Colors.red, size: 16)
                                    //                 onPressed: FirebaseFirestore('reviews').doc(courseId).update,),
                                    //                 SizedBox(width: 4),
                                    //                 Text(like),
                                    //                 SizedBox(width: 16),
                                    //                 Text(review['timestamp'], style: TextStyle(color: Colors.grey)),
                                    //               ],
                                    //             ),
                                    //           ],
                                    //         ),
                                    //       ),
                                    //     ],
                                    //   ),
                                    // );