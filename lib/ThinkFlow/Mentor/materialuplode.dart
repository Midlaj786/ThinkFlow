import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';

class UploadVideosPage extends StatefulWidget {
  final String courseId;
  const UploadVideosPage({super.key, required this.courseId});

  @override
  _UploadVideosPageState createState() => _UploadVideosPageState();
}

class _UploadVideosPageState extends State<UploadVideosPage> {
  final FirebaseStorage storage =
      FirebaseStorage.instanceFor(bucket: "gs://thinkflow");

  List<Map<String, dynamic>> videos = [];

  Future<void> _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      File file = File(result.files.single.path!);
      String fileName = result.files.single.name;

      if (!file.existsSync()) {
        print("Error: File does not exist!");
        return;
      }

      print("Selected File: $fileName");

      VideoPlayerController controller = VideoPlayerController.file(file);
      await controller.initialize();

      setState(() {
        videos.add({
          'name': fileName,
          'file': file,
          'controller': controller,
          'progress': 0.0,
          'caption': "",
          'status': "Pending",
        });
      });
    } else {
      print("No file selected.");
    }
  }

  Future<void> _uploadVideos() async {
    if (videos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please select a video!")));
      return;
    }
    List<Map<String, String>> videoData = [];
    for (var video in videos) {
      if (video['status'] != "Pending") {
        continue;
      }

      setState(() {
        video['status'] = "Uploading";
      });

      String fileName = "course_videos/${DateTime.now().millisecondsSinceEpoch}_${video['name']}";
      final ref = storage.ref().child(fileName);
      UploadTask uploadTask = ref.putFile(video['file']);
      uploadTask.snapshotEvents.listen((event) {
        setState(() {
          video['progress'] = event.bytesTransferred / event.totalBytes;
        });
      });
      await uploadTask;
      String downloadUrl = await ref.getDownloadURL();
      videoData.add({'url': downloadUrl, 'caption': video['caption']});

      setState(() {
        video['status'] = "Uploaded";
      });
    }

    await FirebaseFirestore.instance.collection('courses').doc(widget.courseId).update({'videos': videoData});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Videos Uploaded Successfully!")));
  }

  @override
  void dispose() {
    for (var video in videos) {
      video['controller'].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Course Videos")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickVideo,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_upload, size: 50, color: Colors.blue),
                      SizedBox(height: 10),
                      Text("Browse file to upload", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SizedBox(height: 200,
                child: ListView.builder(
                  itemCount: videos.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            FutureBuilder(
                              future: videos[index]['controller'].initialize(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.done) {
                                  return AspectRatio(
                                    aspectRatio: videos[index]['controller'].value.aspectRatio,
                                    child: VideoPlayer(videos[index]['controller']),
                                  );
                                } else {
                                  return const Center(child: CircularProgressIndicator());
                                }
                              },
                            ),
                            const SizedBox(height: 10),
                            LinearProgressIndicator(value: videos[index]['progress']),
                            const SizedBox(height: 10),
                            TextField(
                              decoration: const InputDecoration(labelText: "Enter Video Caption"),
                              onChanged: (text) {
                                setState(() {
                                  videos[index]['caption'] = text;
                                });
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(videos[index]['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                videos[index]['status'] == "Uploaded"
                                    ? const Icon(Icons.check_circle, color: Colors.green)
                                    : videos[index]['status'] == "Uploading"
                                        ? const Icon(Icons.upload_file, color: Colors.blue)
                                        : const Icon(Icons.hourglass_empty, color: Colors.orange),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: _uploadVideos, child: const Text("Upload Videos")),
          ],
        ),
      ),
    );
  }
}
