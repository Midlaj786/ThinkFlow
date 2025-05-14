// import 'package:flutter/material.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:firebase_database/firebase_database.dart';

// const String appId = "a769d772d7bd4b168bf05a698fe8d4b0";
// const String? token = null;

// class VideoCallScreen extends StatefulWidget {
//   final String channelName;
//   final bool isMentor;

//   const VideoCallScreen({required this.channelName, required this.isMentor});

//   @override
//   _VideoCallScreenState createState() => _VideoCallScreenState();
// }

// class _VideoCallScreenState extends State<VideoCallScreen> {
//   final _users = <int>[];
//   RtcEngine? _engine;
//   bool _muted = false;
//   bool _videoPaused = false;
//   final database = FirebaseDatabase.instance;

//   @override
//   void initState() {
//     super.initState();
//     initAgora();
//     if (widget.isMentor) listenForJoinRequests();
//     else requestToJoinMeeting();
//   }

//   Future<void> initAgora() async {
//     await [Permission.camera, Permission.microphone].request();

//     _engine = createAgoraRtcEngine();
//     await _engine!.initialize(RtcEngineContext(appId: appId));
//     await _engine!.enableVideo();

//     _engine!.registerEventHandler(RtcEngineEventHandler(
//       onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
//         print("Local user joined: ${connection.localUid}");
//       },
//       onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
//         setState(() => _users.add(remoteUid));
//       },
//       onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
//         setState(() => _users.remove(remoteUid));
//       },
//     ));

//     await _engine!.joinChannel(
//       token: token ?? '',
//       channelId: widget.channelName,
//       uid: 0,
//       options: const ChannelMediaOptions(),
//     );
//   }

//   void listenForJoinRequests() {
//     final ref = database.ref('calls/${widget.channelName}/requests');
//     ref.onChildAdded.listen((event) async {
//       final joiningUid = event.snapshot.key!;
//       final result = await showDialog(
//         context: context,
//         builder: (_) => AlertDialog(
//           title: Text("Join Request"),
//           content: Text("User $joiningUid wants to join."),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 database.ref('calls/${widget.channelName}/responses/$joiningUid').set("accepted");
//                 Navigator.pop(context);
//               },
//               child: Text("Accept"),
//             ),
//             TextButton(
//               onPressed: () {
//                 database.ref('calls/${widget.channelName}/responses/$joiningUid').set("denied");
//                 Navigator.pop(context);
//               },
//               child: Text("Deny"),
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   void requestToJoinMeeting() async {
//     final uid = DateTime.now().millisecondsSinceEpoch.toString();
//     final requestRef = database.ref('calls/${widget.channelName}/requests/$uid');
//     final responseRef = database.ref('calls/${widget.channelName}/responses/$uid');

//     await requestRef.set(true);

//     responseRef.onValue.listen((event) {
//       final response = event.snapshot.value;
//       if (response == "accepted") {
//         initAgora(); // Only join after accepted
//       } else if (response == "denied") {
//         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Join request denied.")));
//         Navigator.pop(context);
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _users.clear();
//     _engine?.leaveChannel();
//     _engine?.release();
//     super.dispose();
//   }

//   Widget _videoView(int uid) => Expanded(
//         child: AgoraVideoView(
//           controller: VideoViewController.remote(
//             rtcEngine: _engine!,
//             canvas: VideoCanvas(uid: uid),
//             connection: RtcConnection(channelId: widget.channelName),
//           ),
//         ),
//       );

//   Widget _localVideoView() => AgoraVideoView(
//         controller: VideoViewController(
//           rtcEngine: _engine!,
//           canvas: const VideoCanvas(uid: 0),
//         ),
//       );

//   void _onToggleMute() {
//     setState(() => _muted = !_muted);
//     _engine?.muteLocalAudioStream(_muted);
//   }

//   void _onToggleCamera() {
//     setState(() => _videoPaused = !_videoPaused);
//     _engine?.muteLocalVideoStream(_videoPaused);
//   }

//   void _onSwitchCamera() {
//     _engine?.switchCamera();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Video Call: ${widget.channelName}')),
//       body: _engine == null
//           ? const Center(child: CircularProgressIndicator())
//           : Column(
//               children: [
//                 Expanded(
//                   child: GridView.count(
//                     crossAxisCount: 2,
//                     children: [
//                       Padding(padding: EdgeInsets.all(4), child: _localVideoView()),
//                       for (final uid in _users)
//                         Padding(padding: EdgeInsets.all(4), child: _videoView(uid)),
//                     ],
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       IconButton(
//                         icon: Icon(_muted ? Icons.mic_off : Icons.mic),
//                         onPressed: _onToggleMute,
//                       ),
//                       IconButton(
//                         icon: Icon(_videoPaused ? Icons.videocam_off : Icons.videocam),
//                         onPressed: _onToggleCamera,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.switch_camera),
//                         onPressed: _onSwitchCamera,
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//     );
//   }
// }
