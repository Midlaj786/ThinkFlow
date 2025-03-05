// import 'package:flutter/material.dart';
// import 'package:thinkflow/ThinkFlow/widgets.dart';

// class MentorLoginPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: Text(
//           'Mentor Registration',
//           style: TextStyle(
//             fontSize: 22,
//             fontWeight: FontWeight.bold,
//             color: Colors.black,
//           ),
//         ),
//         backgroundColor: Colors.transparent,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Center(
//               child: Stack(
//                 children: [
//                   CircleAvatar(
//                     radius: 50,
//                     backgroundImage:
//                         AssetImage('assets/profile_placeholder.png'),
//                   ),
//                   Positioned(
//                     bottom: 0,
//                     right: 0,
//                     child: CircleAvatar(
//                       radius: 14,
//                       backgroundColor: Colors.orange,
//                       child: Icon(Icons.edit, color: Colors.white),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(height: 16),
//             Text(
//               'Become a Mentor',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//                 color: Colors.orange,
//               ),
//             ),
//             SizedBox(height: 16),
//             TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 labelText: 'Full Name',
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//               ),
//             ),
//             SizedBox(height: 16),
//             DropdownButtonFormField<String>(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 labelText: 'Select Profession',
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//               ),
//               items: [
//                 'Software Developer',
//                 'Data Scientist',
//                 'Graphic Designer',
//                 'Marketing Expert',
//                 'Other',
//               ].map((profession) {
//                 return DropdownMenuItem(
//                   value: profession,
//                   child: Text(profession),
//                 );
//               }).toList(),
//               onChanged: (value) {},
//             ),
//             SizedBox(height: 16),
//             TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 labelText: 'Years of Experience',
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//               ),
//               keyboardType: TextInputType.number,
//             ),
//             SizedBox(height: 16),
//             TextField(
//               decoration: InputDecoration(
//                 filled: true,
//                 fillColor: Colors.grey[200],
//                 labelText: 'Skills & Expertise',
//                 border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10.0)),
//               ),
//             ),
//             SizedBox(height: 24),
//             Center(child: buildContinueButton('Submit', context)),
//           ],
//         ),
//       ),
//     );
//   }
// }
