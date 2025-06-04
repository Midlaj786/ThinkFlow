import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';


import 'package:thinkflow/ThinkFlow/Theme.dart';
import 'package:video_player/video_player.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CourseVideoPlayer extends StatefulWidget {
  final String courseId;
  final int startIndex;

  const CourseVideoPlayer({
    Key? key,
    required this.courseId,
    required this.startIndex,
  }) : super(key: key);

  @override
  State<CourseVideoPlayer> createState() => _CourseVideoPlayerState();
}

class _CourseVideoPlayerState extends State<CourseVideoPlayer> {
  late VideoPlayerController _controller;
  List<dynamic> _videos = [];
  int _currentIndex = 0;
  bool _showControls = true;
  bool _loadingVideos = true;
  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  bool _isChangingVideo = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.startIndex;
    _loadVideosAndInitPlayer();
  }

  Future<void> _loadVideosAndInitPlayer() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .get();

      _videos = List.from(doc['videos'] ?? []);
      if (_videos.isEmpty) throw Exception('No videos found');

      _initializeController(_videos[_currentIndex]['url']);
    } catch (e) {
      debugPrint('❌ Firestore error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load course videos.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loadingVideos = false);
    }
  }

  void _initializeController(String url) {
    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (!mounted) return;
      if (_controller.value.position == _controller.value.duration) {
        setState(() => _showControls = true);
      }
    });
  }

  void _toggleControls() => setState(() => _showControls = !_showControls);

  void _enterFullscreen() async {
    final isPortrait = _controller.value.size.aspectRatio < 1;
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    await SystemChrome.setPreferredOrientations([
      isPortrait
          ? DeviceOrientation.portraitUp
          : DeviceOrientation.landscapeLeft,
    ]);
    setState(() => _isFullscreen = true);
  }

  void _exitFullscreen() async {
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    setState(() => _isFullscreen = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    _exitFullscreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeprovider = Provider.of<ThemeProvider>(context);

    if (_loadingVideos) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentVid = _videos[_currentIndex];

    return WillPopScope(
      onWillPop: () async {
        if (_isFullscreen) {
          _exitFullscreen();
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: _isFullscreen
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
                elevation: 0,
              ),
        body: SafeArea(
          child: Column(
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
                          : const Center(child: CircularProgressIndicator()),
                      if (_controller.value.isBuffering)
                        const Center(child: CircularProgressIndicator()),
                      if (_showControls) _buildControls(themeprovider),
                    ],
                  ),
                ),
              ),
              if (!_isFullscreen)
                // Use Expanded with a SingleChildScrollView to make the content scrollable
                Expanded(
                  child: SingleChildScrollView( // Add SingleChildScrollView here
                    child: _buildContent(themeprovider, currentVid),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls(ThemeProvider themeprovider) {
    return Container(
      color: Colors.black54,
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          VideoProgressIndicator(
            _controller,
            allowScrubbing: true,
            colors: const VideoProgressColors(
              playedColor: Colors.orange,
              bufferedColor: Colors.white54,
              backgroundColor: Colors.white30,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10, color: Colors.white),
                onPressed: () {
                  final newPosition = _controller.value.position -
                      const Duration(seconds: 10);
                  _controller.seekTo(
                      newPosition > Duration.zero ? newPosition : Duration.zero);
                },
              ),
              IconButton(
                icon: Icon(
                  _controller.value.isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
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
              IconButton(
                icon: const Icon(Icons.forward_10, color: Colors.white),
                onPressed: () {
                  final max = _controller.value.duration;
                  final newPosition = _controller.value.position +
                      const Duration(seconds: 10);
                  _controller.seekTo(
                      newPosition < max ? newPosition : max);
                },
              ),
              Text(
                '${_fmt(_controller.value.position)} / ${_fmt(_controller.value.duration)}',
                style: const TextStyle(color: Colors.white),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: _enterFullscreen,
              ),
              PopupMenuButton<double>(
                initialValue: _playbackSpeed,
                color: themeprovider.backgroundColor,
                onSelected: (v) {
                  setState(() {
                    _playbackSpeed = v;
                    _controller.setPlaybackSpeed(v);
                  });
                },
                itemBuilder: (_) => [0.5, 1.0, 1.5, 2.0]
                    .map((s) => PopupMenuItem(
                          value: s,
                          child: Text('Speed x$s'),
                        ))
                    .toList(),
                child: const Icon(Icons.speed, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) =>
      '${d.inMinutes.remainder(60).toString().padLeft(2, '0')}:' +
      '${d.inSeconds.remainder(60).toString().padLeft(2, '0')}';

  Widget _buildContent(ThemeProvider theme, dynamic currentVid) {
    // Removed the SingleChildScrollView from here, as it's now wrapped in the parent Column
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentVid['caption'] ?? '',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _actionBtn(Icons.thumb_up, 'Like'),
              _actionBtn(Icons.bookmark_border, 'Save'),
              _actionBtn(Icons.share, 'Share'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'More in this course',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 12),
          _buildRelatedVideos(theme),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(height: 4),
        Text(text, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildRelatedVideos(ThemeProvider theme) {
    final others = List.generate(_videos.length, (i) => i);

    return Column(
      children: others.map((i) {
        final vid = _videos[i];
        final isSelected = i == _currentIndex;
        return ListTile(
          tileColor: isSelected ? Colors.orange.withOpacity(0.2) : null,
          leading:
              const Icon(Icons.play_circle_fill, color: Colors.white, size: 40),
          title: Text(vid['caption'], style: const TextStyle(color: Colors.white)),
          subtitle: Text('Video ${i + 1}', style: const TextStyle(color: Colors.white70)),
          onTap: () async {
            if (_isChangingVideo || i == _currentIndex) return;
            _isChangingVideo = true;
            await _controller.pause();
            await _controller.dispose();
            if (!mounted) return;
            setState(() => _currentIndex = i);
            _initializeController(vid['url']);
            _isChangingVideo = false;
          },
        );
      }).toList(),
    );
  }
}