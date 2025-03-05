// import 'package:flutter/material.dart';
// import 'package:thinkflow/ThinkFlow/courseuplode.dart';
// import 'package:thinkflow/ThinkFlow/llll.dart';

// class HomePageScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       drawer: Drawer(
//         child: Column(
//           children: [
//             ListTile(
//               title: Text("Become a Mentor"),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => MentorLoginPage()));
//               },
//             ),
//             ListTile(
//               title: Text("Courses"),
//               onTap: () {
//                 Navigator.push(context,
//                     MaterialPageRoute(builder: (context) => Courseuplode()));
//               },
//             ),
//           ],
//         ),
//       ),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         actions: [
//           const Padding(
//             padding: EdgeInsets.all(8.0),
//             child: CircleAvatar(backgroundColor: Colors.black, radius: 16),
//           )
//         ],
//         title: const Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.language, color: Colors.orange, size: 30),
//             SizedBox(width: 5),
//             Text(
//               "ThinkFlow",
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.orange,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: SingleChildScrollView(
//           scrollDirection: Axis.vertical,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: const TextField(
//                   decoration: InputDecoration(
//                     hintText: 'Search for ...',
//                     border: InputBorder.none,
//                     suffixIcon: Icon(Icons.search, color: Colors.orange),
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 height: MediaQuery.of(context).size.height * 0.3,
//                 decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(12),
//                   color: Colors.black,
//                   // image: const DecorationImage(
//                   //   image: AssetImage('assets/download.jpg'),
//                   //   fit: BoxFit.cover,
//                   // ),
//                 ),
//               ),
//               const SizedBox(height: 16),
//               const Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text('Popular Courses',
//                       style:
//                           TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                   Text('SEE ALL',
//                       style: TextStyle(color: Colors.blue, fontSize: 14)),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               const Row(
//                 children: [
//                   Chip(label: Text('All')),
//                   SizedBox(width: 8),
//                   Chip(
//                       label: Text('Graphic Design',
//                           style: TextStyle(color: Colors.white)),
//                       backgroundColor: Colors.green),
//                   SizedBox(width: 8),
//                   Chip(label: Text('Web Development')),
//                 ],
//               ),
//               const SizedBox(height: 16),

//               Container(
//                 height: 250,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 4,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       width: 150,
//                       margin: const EdgeInsets.only(right: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           const BoxShadow(color: Colors.black12, blurRadius: 4)
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Container(
//                               decoration: const BoxDecoration(
//                                 color: Colors.black,
//                                 borderRadius: BorderRadius.vertical(
//                                     top: Radius.circular(12)),
//                               ),
//                             ),
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Text('Graphic Design Advanced',
//                                     style:
//                                         TextStyle(fontWeight: FontWeight.bold)),
//                                 SizedBox(height: 4),
//                                 Row(
//                                   children: [
//                                     Text('\$10',
//                                         style: TextStyle(color: Colors.blue)),
//                                     Spacer(),
//                                     Icon(Icons.star,
//                                         color: Colors.yellow, size: 16),
//                                     Text('4.2'),
//                                   ],
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               SizedBox(height: 16),
// // "Top Mentors" section
//               const Text(
//                 'Top Mentors',
//                 style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 8),
//               Container(
//                 height: 120,
//                 child: ListView.builder(
//                   scrollDirection: Axis.horizontal,
//                   itemCount: 5,
//                   itemBuilder: (context, index) {
//                     return Container(
//                       width: 80,
//                       margin: EdgeInsets.only(right: 16),
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.black,
//                         image: DecorationImage(
//                           image: AssetImage('assets/mentor${index + 1}.png'),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       alignment: Alignment.center, // Center the text
//                       child: Text(
//                         'Shammas',
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                         textAlign: TextAlign.center,
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
