import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/ThinkFlow/Mentor/mentorview.dart';
import 'package:thinkflow/ThinkFlow/Theme.dart';

import 'package:thinkflow/ThinkFlow/Mentor/mentprof.dart';

class MentorSearch extends StatefulWidget {
  @override
  _MentorSearchState createState() => _MentorSearchState();
}

class _MentorSearchState extends State<MentorSearch> {
  String selectedProfession = "All";
  List<String> professions = ["All"];
  String searchQuery = "";
  bool showSuggestions = false;


  @override
  void initState() {
    super.initState();
    _fetchProfessions();
  }

  Future<void> _fetchProfessions() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('mentors').get();
    Set<String> uniqueProfessions = {};
    for (var doc in snapshot.docs) {
      uniqueProfessions.add(doc['profession']);
    }
    setState(() {
      professions.addAll(uniqueProfessions.toList());
    });
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
        title: Text(
          "Search Mentors",
          style: TextStyle(
            color: themeProvider.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          _buildSearchBar(themeProvider),
          _buildProfessionChips(),
          Expanded(child: _buildMentorList(themeProvider)),
        ],
      ),
    );
  }

 Widget _buildSearchBar(ThemeProvider themeProvider) {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Column(
      children: [
        TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value.toLowerCase();
            });
          },
          decoration: InputDecoration(
            hintText: "Search mentors or profession...",
            prefixIcon: Icon(Icons.search, color: Colors.grey),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (searchQuery.isNotEmpty) _buildSuggestions(themeProvider), // show suggestions
      ],
    ),
  );
}

Widget _buildSuggestions(ThemeProvider themeProvider) {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
    builder: (context, snapshot) {
      if (!snapshot.hasData) return SizedBox();

      final docs = snapshot.data!.docs;
      final List<Widget> suggestions = [];

      for (var doc in docs) {
        String name = (doc['name'] ?? '').toString().toLowerCase();
        String profession = (doc['profession'] ?? '').toString().toLowerCase();
        String profileImg = (doc['profileimg'] ?? '').toString();

        // Suggest profession
        if (profession.contains(searchQuery)) {
          suggestions.add(
            ListTile(
              leading: Icon(Icons.work,color:Colors.grey,),
              title: Text(profession,style: TextStyle(color:themeProvider.textColor )),
              onTap: () {
                setState(() {
                  selectedProfession = profession;
                  searchQuery = '';
                });
              },
            ),
          );
        }

        // Suggest mentor
        if (name.contains(searchQuery) || profession.contains(searchQuery)) {
          suggestions.add(
            ListTile(
              leading: CircleAvatar(
                backgroundImage: profileImg.isNotEmpty
                    ? NetworkImage(profileImg)
                    : null,
                child: profileImg.isEmpty ? Icon(Icons.person) : null,
              ),
              title: Text(doc['name'] ?? 'Unknown',style: TextStyle(color:themeProvider.textColor ),),
              subtitle: Text(doc['profession'] ?? 'N/A',style: TextStyle(color:Colors.grey )),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MentorScreen(mentorId: doc.id),
                  ),
                );
              },
            ),
          );
        }
      }

      return Column(children: suggestions.take(5).toList());
    },
  );
}



  Widget _buildProfessionChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: professions.map((profession) {
          bool isSelected = profession == selectedProfession;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(profession),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedProfession = profession;
                });
              },
              selectedColor: Colors.green,
              backgroundColor: Colors.grey[200],
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMentorList(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var mentors = snapshot.data!.docs.where((mentor) {
            final name = mentor['name'].toString().toLowerCase();
            final profession = mentor['profession'].toString().toLowerCase();

            return (selectedProfession == "All" ||
                    profession == selectedProfession.toLowerCase()) &&
                (name.contains(searchQuery) || profession.contains(searchQuery));
          }).toList();

          if (mentors.isEmpty) {
            return const Center(child: Text("No mentors found"));
          }

          return GridView.builder(
            itemCount: mentors.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.9,
            ),
            itemBuilder: (context, index) {
              var mentor = mentors[index];
              return _buildMentorCard(
                name: mentor['name'] ?? 'Unknown',
                profession: mentor['profession'] ?? 'N/A',
                imageUrl: mentor['profileimg'] ?? '',
                themeProvider: themeProvider,
              );
            },
          );
        },
      ),
    );
  }

 Widget _buildMentorCard({
  required String name,
  required String profession,
  required String imageUrl,
  required ThemeProvider themeProvider,
}) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[300],
        onBackgroundImageError: (_, __) {},
      ),
      const SizedBox(height: 12),
      Text(
        name,
        textAlign: TextAlign.center,
        style:  TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color:themeProvider.textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Text(
        profession,
        style: const TextStyle(color: Colors.grey, fontSize: 14),
        textAlign: TextAlign.center,
      ),
    ],
  );
}
}
