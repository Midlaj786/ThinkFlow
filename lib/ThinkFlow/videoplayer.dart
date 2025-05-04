import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CourseVideoPlayer extends StatefulWidget {
  final String videoUrl;

  CourseVideoPlayer({required this.videoUrl});

  @override
  _CourseVideoPlayerState createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (_controller.value.position == _controller.value.duration) {
        setState(() => _showControls = true);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: _toggleControls,
            child: AspectRatio(
              aspectRatio: _controller.value.isInitialized
                  ? _controller.value.aspectRatio
                  : 16 / 9,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  _controller.value.isInitialized
                      ? VideoPlayer(_controller)
                      : Center(child: CircularProgressIndicator(color: Colors.orange)),
                  if (_showControls) _buildControls(),
                ],
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVideoInfo(),
                  _buildActionButtons(),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text("Related Videos", style: TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                  _buildRelatedVideos(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            padding: EdgeInsets.symmetric(vertical: 8),
            colors: VideoProgressColors(
              playedColor: Colors.orange,
              backgroundColor: Colors.white30,
              bufferedColor: Colors.white54,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
              ),
              Text(
                "${_formatDuration(_controller.value.position)} / ${_formatDuration(_controller.value.duration)}",
                style: TextStyle(color: Colors.white),
              ),
              PopupMenuButton<double>(
                initialValue: _playbackSpeed,
                color: Colors.white,
                onSelected: (value) {
                  setState(() {
                    _playbackSpeed = value;
                    _controller.setPlaybackSpeed(value);
                  });
                },
                itemBuilder: (_) => [0.5, 1.0, 1.5, 2.0]
                    .map((speed) => PopupMenuItem(
                          value: speed,
                          child: Text("Speed x$speed"),
                        ))
                    .toList(),
                child: Icon(Icons.speed, color: Colors.white),
              ),
              IconButton(
                icon: Icon(Icons.fullscreen, color: Colors.white),
                onPressed: () {
                  // Optional: Add full-screen logic
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Widget _buildVideoInfo() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Flutter Video Course - Part 1",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            "Learn how to build apps with Flutter in this course.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _actionButton(Icons.thumb_up, "Like"),
          _actionButton(Icons.bookmark_border, "Save"),
          _actionButton(Icons.share, "Share"),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildRelatedVideos() {
    return Column(
      children: List.generate(3, (index) {
        return ListTile(
          leading: Container(
            width: 80,
            height: 45,
            color: Colors.grey,
            child: Icon(Icons.play_circle_fill, color: Colors.white),
          ),
          title: Text("Related Video ${index + 1}", style: TextStyle(color: Colors.white)),
          subtitle: Text("5 mins • Flutter", style: TextStyle(color: Colors.white70)),
          onTap: () {
            // Replace with logic to play another video
          },
        );
      }),
    );
  }
}
