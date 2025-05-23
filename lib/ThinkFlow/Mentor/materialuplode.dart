// Full revised code based on Midlaj's new requirements

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:thinkflow/ThinkFlow/videoplayer.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:thinkflow/amplifyconfiguration.dart';

class UploadVideosPage extends StatefulWidget {
  final String courseId;
  const UploadVideosPage({super.key, required this.courseId});

  @override
  State<UploadVideosPage> createState() => _UploadVideosPageState();
}

class _UploadVideosPageState extends State<UploadVideosPage> {
  List<Map<String, dynamic>> existingVideos = [];
  bool _amplifyConfigured = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _fetchExistingVideos();
    _configureAmplify();
  }

  Future<void> _configureAmplify() async {
    if (!_amplifyConfigured) {
      try {
        await Amplify.addPlugin(AmplifyStorageS3());
        await Amplify.configure(amplifyconfig);
        _amplifyConfigured = true;
      } catch (e) {
        print("Amplify configuration error: $e");
      }
    }
  }

  Future<void> _fetchExistingVideos() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('courses')
        .doc(widget.courseId)
        .get();
    List<dynamic> existing = snapshot['videos'] ?? [];
    setState(() {
      existingVideos = existing
          .asMap()
          .entries
          .map<Map<String, dynamic>>((entry) => {
                'index': entry.key + 1,
                'url': entry.value['url'],
                'caption': entry.value['caption'],
              })
          .toList();
    });
  }

  Future<void> _pickAndUploadVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;

    File file = File(result.files.single.path!);
    String fileName = result.files.single.name;

    TextEditingController captionController = TextEditingController();
    bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter Caption'),
        content: TextField(
          controller: captionController,
          decoration: const InputDecoration(hintText: 'Enter caption'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                if (captionController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(true);
                }
              },
              child: const Text('Upload')),
        ],
      ),
    );

    if (confirmed != true) return;

    String caption = captionController.text.trim();
    String key =
        "course_videos/${DateTime.now().millisecondsSinceEpoch}_$fileName";

    try {
      double progressValue = 0.0;
      setState(() => _isUploading = true);

      final UploadFileResult result = await Amplify.Storage.uploadFile(
        local: file,
        key: key,
        onProgress: (progress) {
          setState(() => progressValue = progress.getFractionCompleted());
        },
      );

      final urlResult =
          "https://thinkflowimages36926-dev.s3.us-east-1.amazonaws.com/public/$key";

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update({
        'videos': FieldValue.arrayUnion([
          {'url': urlResult, 'caption': caption}
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Video uploaded successfully.")),
      );

      _fetchExistingVideos();
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Upload failed.")),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Widget _buildExistingVideoCard(Map<String, dynamic> video) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(video['index'].toString()),
        ),
        title: Text(video['caption'] ?? 'No caption'),
        subtitle: Text(video['url'], style: const TextStyle(fontSize: 12)),
        trailing: IconButton(
          icon: const Icon(Icons.play_circle_fill),
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => CourseVideoPlayer(videoUrl: video['url']),
            ));
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Upload Course Videos")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: _isUploading ? null : _pickAndUploadVideo,
              icon: const Icon(Icons.add),
              label: const Text("Pick & Upload Video"),
            ),
            const SizedBox(height: 20),
            const Text("Existing Videos",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: existingVideos.length,
                itemBuilder: (context, index) =>
                    _buildExistingVideoCard(existingVideos[index]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class VideoPlayerPage extends StatefulWidget {
//   final String videoUrl;
//   const VideoPlayerPage({super.key, required this.videoUrl});

//   @override
//   State<VideoPlayerPage> createState() => _VideoPlayerPageState();
// }

// class _VideoPlayerPageState extends State<VideoPlayerPage> {
//   late VideoPlayerController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = VideoPlayerController.network(widget.videoUrl)
//       ..initialize().then((_) {
//         setState(() {});
//         _controller.play();
//       });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Preview Video")),
//       body: Center(
//         child: _controller.value.isInitialized
//             ? AspectRatio(
//                 aspectRatio: _controller.value.aspectRatio,
//                 child: VideoPlayer(_controller),
//               )
//             : const CircularProgressIndicator(),
//       ),
//     );
//   }
// }
