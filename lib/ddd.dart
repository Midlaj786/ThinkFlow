// import 'package:flutter/material.dart';

// class ChatScreen extends StatelessWidget {
//   final List<Map<String, String>> messages = [
//     {'received': 'Hi, Midlaj Good Morning', 'time': '10:00 am'},
//     {'received': 'Please Update your project', 'time': '10:00 am'},
//     {'sent': 'Good Morning', 'time': '10:02 am'},
//     {'sent': 'Ok, I will Update it Soon', 'time': '10:03 am'},
//   ];

//   const ChatScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Row(
//           children: [
//             CircleAvatar(backgroundColor: Colors.black),
//             SizedBox(width: 8),
//             Text('Rahul',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Expanded(
//             child: ListView.builder(
//               padding: const EdgeInsets.all(16),
//               itemCount: messages.length,
//               itemBuilder: (context, index) {
//                 final message = messages[index];
//                 if (message.containsKey('received')) {
//                   return _buildReceivedMessage(
//                       message['received']!, message['time']!);
//                 } else {
//                   return _buildSentMessage(message['sent']!, message['time']!);
//                 }
//               },
//             ),
//           ),
//           _buildMessageInput(),
//         ],
//       ),
//     );
//   }

//   Widget _buildReceivedMessage(String message, String time) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         constraints: const BoxConstraints(maxWidth: 250),
//         decoration: BoxDecoration(
//           color: Colors.grey[600],
//           borderRadius: const BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//             bottomRight: Radius.circular(12),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           // mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(message, style: const TextStyle(color: Colors.white)),
//             const SizedBox(height: 4),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Text(time,
//                   style: const TextStyle(fontSize: 10, color: Colors.white70)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSentMessage(String message, String time) {
//     return Align(
//       alignment: Alignment.centerRight,
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 4),
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         constraints: const BoxConstraints(maxWidth: 250),
//         decoration: const BoxDecoration(
//           color: Colors.teal,
//           borderRadius: BorderRadius.only(
//             topLeft: Radius.circular(12),
//             topRight: Radius.circular(12),
//             bottomLeft: Radius.circular(12),
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           // mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(message, style: const TextStyle(color: Colors.white)),
//             const SizedBox(height: 4),
//             Align(
//               alignment: Alignment.bottomRight,
//               child: Text(time,
//                   style: const TextStyle(fontSize: 10, color: Colors.white70)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildMessageInput() {
//     return Padding(
//       padding: const EdgeInsets.all(8.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[300],
//                 borderRadius: BorderRadius.circular(24),
//               ),
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: const TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Message',
//                   border: InputBorder.none,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           const CircleAvatar(
//             backgroundColor: Colors.orange,
//             child: Icon(Icons.mic, color: Colors.white),
//           ),
//         ],
//       ),
//     );
//   }
// }