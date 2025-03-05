import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:typed_data';

class UploadFilesPage extends StatefulWidget {
  final String courseId;

  UploadFilesPage({required this.courseId});

  @override
  _UploadFilesPageState createState() => _UploadFilesPageState();
}

class _UploadFilesPageState extends State<UploadFilesPage> {
  List<Map<String, dynamic>> files = []; // Stores file details

  Future<void> _pickFile(int index) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      setState(() {
        files[index] = {
          'name': result.files.single.name,
          'bytes': result.files.single.bytes, // Uint8List for web
          'file': result.files.single.path != null
              ? File(result.files.single.path!)
              : null,
        };
      });
    }
  }

  Future<void> _uploadFiles() async {
    if (files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select at least one file!")),
      );
      return;
    }

    List<String> fileUrls = [];
    final storageRef = FirebaseStorage.instance.ref();

    for (var fileData in files) {
      String fileName =
          "${DateTime.now().millisecondsSinceEpoch}_${fileData['name']}";
      final ref = storageRef.child("course_files/$fileName");

      if (fileData['file'] != null) {
        await ref.putFile(fileData['file']);
      } else if (fileData['bytes'] != null) {
        await ref.putData(fileData['bytes']);
      }

      String downloadUrl = await ref.getDownloadURL();
      fileUrls.add(downloadUrl);
    }

    await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .update({
      'files': fileUrls,
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Files Uploaded!")));
  }

  @override
  void initState() {
    super.initState();
    files.add({'name': "Select File", 'file': null, 'bytes': null});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Course Files"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ...List.generate(files.length, (index) {
              return Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickFile(index),
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              files[index]['name'],
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(Icons.upload_file),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                ],
              );
            }),
            IconButton(
              icon: Icon(Icons.add_circle, size: 30, color: Colors.blue),
              onPressed: () {
                setState(() {
                  files.add(
                      {'name': "Select File", 'file': null, 'bytes': null});
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadFiles,
              child: Text("Submit Files"),
            ),
          ],
        ),
      ),
    );
  }
}
