import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';

class AdminMentorsPage extends StatefulWidget {
  @override
  _AdminMentorsPageState createState() => _AdminMentorsPageState();
}

class _AdminMentorsPageState extends State<AdminMentorsPage> {
  String selectedProfession = "All";
  List<String> professions = ["All"];

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
        title: Text("Manage Mentors",
            style: TextStyle(color: themeProvider.textColor, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          _buildFilterDropdown(themeProvider),
          Expanded(child: _buildMentorList(themeProvider)),
        ],
      ),
    );
  }

  /// **Profession Filter Dropdown**
  Widget _buildFilterDropdown(ThemeProvider themeProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: DropdownButtonFormField<String>(
        value: selectedProfession,
        items: professions.map((String profession) {
          return DropdownMenuItem<String>(
            value: profession,
            child: Text(profession),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            selectedProfession = value!;
          });
        },
        decoration: InputDecoration(
          filled: true,
          fillColor: themeProvider.isDarkMode ? Colors.grey[800] : Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: "Filter by Profession",
        ),
      ),
    );
  }

  /// **Mentors ListView**
  Widget _buildMentorList(ThemeProvider themeProvider) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('mentors').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Center(child: CircularProgressIndicator());

        var mentors = snapshot.data!.docs.where((doc) {
          return selectedProfession == "All" || doc['profession'] == selectedProfession;
        }).toList();

        if (mentors.isEmpty) {
          return Center(child: Text("No mentors available."));
        }

        return ListView.builder(
          itemCount: mentors.length,
          itemBuilder: (context, index) {
            var mentor = mentors[index].data();
            return Card(
              margin: EdgeInsets.all(8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: mentor['profileImage'] != null
                    ? Image.network(mentor['profileImage'], width: 50, height: 50, fit: BoxFit.cover)
                    : Icon(Icons.person, size: 40),
                title: Text(mentor['name'], style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Profession: ${mentor['profession']}"),
                trailing: Icon(Icons.arrow_forward_ios, color: themeProvider.textColor),
                onTap: () {
                  // Navigate to mentor details if needed
                },
              ),
            );
          },
        );
      },
    );
  }
}
