import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:thinkflow/thinkflow/Theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_storage_s3/amplify_storage_s3.dart';
import 'package:thinkflow/amplifyconfiguration.dart';
import 'package:thinkflow/thinkflow/mentor/course.dart';
import 'package:thinkflow/thinkflow/user/video/videoplayer.dart';
import 'package:thinkflow/thinkflow/user/widgets/widgets.dart';

class UploadVideosPage extends StatefulWidget {
  final String courseId;
  UploadVideosPage({super.key, required this.courseId});

  @override
  State<UploadVideosPage> createState() => _UploadVideosPageState();
}

class _UploadVideosPageState extends State<UploadVideosPage> {
  List<Map<String, dynamic>> existingVideos = [];
  bool _amplifyConfigured = false;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  File? _selectedVideo;
  TextEditingController _captionController = TextEditingController();
TextEditingController _titleController = TextEditingController();
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

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
                'title': entry.value['title'] ,
                'caption': entry.value['caption'],

              })
          .toList();
    });
  }

  Future<void> _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result == null) return;
    setState(() {
      _selectedVideo = File(result.files.single.path!);
    });
  }

  Future<void> _uploadVideo() async {
    if (!_formKey.currentState!.validate()) return;

    String fileName = _selectedVideo!.path.split('/').last;
    String key =
        "course_videos/${DateTime.now().millisecondsSinceEpoch}_$fileName";
    String caption = _captionController.text.trim();
String title = _titleController.text.trim();
    try {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0.0;
      });

      await Amplify.Storage.uploadFile(
        local: _selectedVideo!,
        key: key,
        onProgress: (progress) {
          setState(() {
            _uploadProgress = progress.getFractionCompleted();
          });
        },
      );

      String url =
          "https://thinkflowimages36926-dev.s3.us-east-1.amazonaws.com/public/$key";

      await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .update({
        'videos': FieldValue.arrayUnion([
          {'url': url,'title':title ,'caption': caption}
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Video uploaded successfully.")),
      );

      _captionController.clear();
      _selectedVideo = null;
      _fetchExistingVideos();
    } catch (e) {
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed.")),
      );
    } finally {
      setState(() {
        _isUploading = false;
        _uploadProgress = 0.0;
      });
    }
  }

  Widget _buildVideoCard(
      Map<String, dynamic> video, ThemeProvider themeProvider) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.blueAccent.withOpacity(0.1),
          child: Text(video['index'].toString(),
              style: TextStyle(color: Colors.blueAccent)),
        ),
        title: Text(
          video['title'] ,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),subtitle: Text(
          video['caption'] ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(),
        ),
        trailing:
            Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 30),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CourseVideoPlayer(
                courseId: widget.courseId,
                startIndex: video['index'] - 1,
                
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      appBar: AppBar(
        backgroundColor: themeProvider.backgroundColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: themeProvider.textColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Upload Course Videos",
          style: TextStyle(color: themeProvider.textColor),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Form(key:_formKey ,
                child: Column(
                  children: [
                    if (_selectedVideo != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 200,
                            width: double.infinity,
                            color: Colors.black12,
                            child: Center(
                              child: Text(
                                "Video selected: ${_selectedVideo!.path.split('/').last}",
                                style: TextStyle(color: themeProvider.textColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                           TextFormField(
                            controller: _titleController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                            style: TextStyle(color: themeProvider.textColor),
                            maxLength: 100,
                            decoration: InputDecoration(
                              labelText: 'Title',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: themeProvider.textColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          TextFormField(
                            controller: _captionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Caption is required';
                              }
                              return null;
                            },
                            style: TextStyle(color: themeProvider.textColor),
                            maxLength: 100,
                            decoration: InputDecoration(
                              labelText: 'Caption ',
                              border: OutlineInputBorder(),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: themeProvider.textColor),
                              ),
                            ),
                          ),
                          SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: _isUploading ? null : _uploadVideo,
                            icon: Icon(Icons.cloud_upload),
                            label: Text("Upload"),
                          ),
                          if (_isUploading)
                            Column(
                              children: [
                                SizedBox(height: 8),
                                LinearProgressIndicator(value: _uploadProgress),
                                SizedBox(height: 4),
                                Text(
                                  "${(_uploadProgress * 100).toStringAsFixed(0)}% uploaded",
                                  style: TextStyle(color: themeProvider.textColor),
                                ),
                                SizedBox(height: 16),
                              ],
                            ),
                        ],
                      ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Uploaded Videos",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: themeProvider.textColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      height: 300,
                      child: existingVideos.isEmpty
                          ? Center(
                              child: Text(
                                "No videos uploaded yet.",
                                style: TextStyle(color: themeProvider.textColor),
                              ),
                            )
                          : ListView.builder(
                              itemCount: existingVideos.length,
                              itemBuilder: (context, index) =>
                                  _buildVideoCard(existingVideos[index], themeProvider),
                            ),
                    ),
                    SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _pickVideo,
                        icon: Icon(Icons.add),
                        label: Text("Add Video"),
                      ),
                    ),
                    SizedBox(height: 12),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseDetailPage(courseId: widget.courseId),
                          ),
                        );
                      },
                      child: buildContinueButton("Continue", context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
