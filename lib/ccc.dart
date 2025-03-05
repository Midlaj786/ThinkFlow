import 'package:flutter/material.dart';



class ContactScreen extends StatelessWidget {
  final List<Map<String, String>> chats = [
    {
      "name": "Virginia M. Patterson",
      "message": "Hi, Good Evening Bro!",
      "time": "14:59",
      "count": "03"
    },
    {
      "name": "Dominick S. Jenkins",
      "message": "I just Finished It!",
      "time": "08:35",
      "count": "02"
    },
    {
      "name": "Duncan E. Hoffman",
      "message": "How are you?",
      "time": "08:10",
      "count": ""
    },
    {
      "name": "Roy R. McCraney",
      "message": "OMG, This is Amazing..",
      "time": "21:07",
      "count": "06"
    },
    {
      "name": "Janice R. Norris",
      "message": "Wow, This is Really Epic",
      "time": "09:15",
      "count": ""
    },
    {
      "name": "Marilyn C. Amerson",
      "message": "Hi, Good Evening Bro!",
      "time": "14:59",
      "count": "09"
    },
    {
      "name": "Dominick S. Jenkins",
      "message": "I just Finished It!",
      "time": "08:35",
      "count": "02"
    },
    {
      "name": "Beverly J. Barbee",
      "message": "Perfect.!",
      "time": "06:54",
      "count": ""
    },
  ];

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
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search for ...',
                  border: InputBorder.none,
                  suffixIcon: Container(
                      height: MediaQuery.of(context).size.height * 0.01,
                      width: MediaQuery.of(context).size.width * 0.01,
                      color: Colors.orange,
                      child: Icon(Icons.search, color: Colors.white)),
                ),
              ),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.black),
                    title: Text(chats[index]['name']!,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(chats[index]['message']!),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (chats[index]['count']!.isNotEmpty)
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: Colors.orange,
                            child: Text(chats[index]['count']!,
                                style: TextStyle(
                                    fontSize: 12, color: Colors.white)),
                          ),
                        SizedBox(height: 4),
                        Text(chats[index]['time']!,
                            style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
