// import 'package:androidtv/logger/logger_file.dart';
// import 'package:appinio_video_player/appinio_video_player.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// // import 'package:video_player/video_player.dart';
// // import 'package:youtube_player_flutter/youtube_player_flutter.dart';
//
// class YoutubeVideo extends StatefulWidget {
//   const YoutubeVideo({super.key});
//
//   @override
//   State<YoutubeVideo> createState() => _YoutubeVideoState();
// }
//
// class _YoutubeVideoState extends State<YoutubeVideo> {
//   // final VideoPlayerController _controller = VideoPlayerController.networkUrl(
//   //   Uri.parse("https://rl-video.ralphlauren.com/v2/2025/06/20250603-home-lp/RL-Hamptons-Home-DSK.mp4"),
//   // );
//   //
//   //
//   // @override
//   // void dispose() {
//   //   _controller.dispose();
//   //   super.dispose();
//   // }
//   // @override
//   // Widget build(BuildContext context) {
//   //   return Scaffold(
//   //     body:VideoPlayer( _controller
//   //       ..initialize().catchError( (error) {
//   //         // Handle error during initialization
//   //         showDialog(
//   //           context: context,
//   //           builder: (b) {
//   //             return AlertDialog(
//   //               title: Text("Error"),
//   //               content: Text("Failed to initialize video at index $error"),
//   //               actions: [TextButton(onPressed: () => Navigator.of(b).pop(), child: Text("OK"))],
//   //             );
//   //           },
//   //         );
//   //       })
//   //
//   //           .then((_) {
//   //         _controller.play();
//   //       })
//   //
//   //
//   //     ),
//   //   );
//   // }
//
//   late VideoPlayerController videoPlayerController;
//   late CustomVideoPlayerController _customVideoPlayerController;
//
//   String videoUrl = "https://rl-video.ralphlauren.com/v2/2025/06/20250603-home-lp/RL-Hamptons-Home-DSK.mp4";
//
//   void func() {
//     try {
//       videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl))
//         ..initialize()
//             .catchError((error) {
//           this.logInfo('VIDEOERROR $error', data: {'timestamp': DateTime.now()});
//               // showDialog(
//               //   context: context,
//               //   builder: (b) {
//               //     return AlertDialog(
//               //       title: Text("Error"),
//               //       content: Text("Failed to initialize video at index $error"),
//               //       actions: [TextButton(onPressed: () => Navigator.of(b).pop(), child: Text("OK"))],
//               //     );
//               //   },
//               // );
//             })
//             .then((value) => setState(() {}));
//       _customVideoPlayerController = CustomVideoPlayerController(
//         context: context,
//         videoPlayerController: videoPlayerController,
//       );
//     } catch (e) {}
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     func();
//   }
//
//   @override
//   void dispose() {
//     _customVideoPlayerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return CupertinoPageScaffold(
//       navigationBar: CupertinoNavigationBar(
//         // middle: Text(widget.title),
//       ),
//       child: SafeArea(child: CustomVideoPlayer(customVideoPlayerController: _customVideoPlayerController)),
//     );
//   }
// }
//
// // }
