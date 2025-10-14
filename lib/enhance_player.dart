// // pubspec.yaml dependencies
// /*
// dependencies:
//   flutter:
//     sdk: flutter
//   video_player: ^2.8.1
//   chewie: ^1.7.4
//   hive: ^2.2.3
//   hive_flutter: ^1.1.0
//   carousel_slider_plus: ^6.0.0
//
// dev_dependencies:
//   hive_generator: ^2.0.1
//   build_runner: ^2.4.7
// */
//
// import 'dart:io';
// import 'package:better_player/better_player.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_carousel_slider/carousel_slider.dart';
// import 'package:flutter_carousel_slider/carousel_slider_transforms.dart';
// import 'package:video_player/video_player.dart';
// import 'package:chewie/chewie.dart';
// import 'package:hive/hive.dart';
//
// import 'db/media_time.dart';
// import 'db/video_type.dart';
//
//
// // Enhanced Video Player Widget
// class EnhancedVideoPlayer extends StatefulWidget {
//   final MediaItem mediaItem;
//   final bool autoPlay;
//   final VoidCallback? onVideoEnded;
//   final VoidCallback? onVideoStarted;
//   final Function(Duration)? onPositionChanged;
//
//   const EnhancedVideoPlayer({
//     Key? key,
//     required this.mediaItem,
//     this.autoPlay = false,
//     this.onVideoEnded,
//     this.onVideoStarted,
//     this.onPositionChanged,
//   }) : super(key: key);
//
//   @override
//   State<EnhancedVideoPlayer> createState() => _EnhancedVideoPlayerState();
// }
//
// class _EnhancedVideoPlayerState extends State<EnhancedVideoPlayer> {
//   VideoPlayerController? _videoController;
//   ChewieController? _chewieController;
//   bool _isInitialized = false;
//   bool _hasError = false;
//   String? _errorMessage;
//
//
//   late BetterPlayerController _betterPlayerController;
//   late BetterPlayerDataSource _betterPlayerDataSource;
//
//   @override
//   void initState() {
//     super.initState();
//     BetterPlayerConfiguration betterPlayerConfiguration =
//     BetterPlayerConfiguration(
//       aspectRatio: 16 / 9,
//       fit: BoxFit.contain,
//       autoPlay: true,
//       looping: true,
//     );
//     _betterPlayerDataSource = BetterPlayerDataSource(
//       BetterPlayerDataSourceType.network,
//       ,
//     );
//     _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);
//     _betterPlayerController.setupDataSource(_betterPlayerDataSource);
//     _initializeVideo();
//   }
//
//   Future<void> _initializeVideo() async {
//     try {
//       // Initialize video controller based on source
//       if (widget.mediaItem.localPath != null && widget.mediaItem.localPath!.isNotEmpty) {
//         _videoController = VideoPlayerController.file(File(widget.mediaItem.localPath!));
//       }
//       // else if (widget.mediaItem.url != null && widget.mediaItem.url!.isNotEmpty) {
//       //   // _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.mediaItem.url!));
//       // }
//       else {
//         throw Exception('No valid video source provided');
//       }
//
//       await _videoController!.initialize();
//
//       // Set up video controller listeners
//       _videoController!.addListener(_videoListener);
//
//       // Create Chewie controller with enhanced settings
//       _chewieController = ChewieController(
//         videoPlayerController: _videoController!,
//         autoPlay: widget.autoPlay,
//         // looping: widget.settings.looping,
//         aspectRatio: _videoController!.value.aspectRatio,
//         autoInitialize: true,
//         // showControls: widget.settings.showControls,
//         // allowFullScreen: widget.settings.allowFullScreen,
//         allowMuting: true,
//         showControlsOnInitialize: false,
//         materialProgressColors: ChewieProgressColors(
//           playedColor: Colors.blue,
//           handleColor: Colors.blueAccent,
//           backgroundColor: Colors.grey,
//           bufferedColor: Colors.lightBlue,
//         ),
//         placeholder: Container(
//           color: Colors.black,
//           child: const Center(
//             child: CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//             ),
//           ),
//         ),
//         errorBuilder: (context, errorMessage) {
//           return Container(
//             color: Colors.black,
//             child: Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   const Icon(
//                     Icons.error_outline,
//                     color: Colors.red,
//                     size: 60,
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Error loading video',
//                     style: TextStyle(color: Colors.white, fontSize: 16),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     errorMessage,
//                     style: TextStyle(color: Colors.grey, fontSize: 12),
//                     textAlign: TextAlign.center,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//
//       // Set volume
//       // await _videoController!.setVolume(widget.settings.volume);
//
//       if (mounted) {
//         setState(() {
//           _isInitialized = true;
//         });
//
//         if (widget.onVideoStarted != null && widget.autoPlay) {
//           widget.onVideoStarted!();
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() {
//           _hasError = true;
//           _errorMessage = e.toString();
//         });
//       }
//     }
//   }
//
//   void _videoListener() {
//     if (_videoController != null && _videoController!.value.isInitialized) {
//       // Check if video ended
//       if (_videoController!.value.position >= _videoController!.value.duration) {
//         if (widget.onVideoEnded != null) {
//           widget.onVideoEnded!();
//         }
//       }
//
//       // Report position changes
//       if (widget.onPositionChanged != null) {
//         widget.onPositionChanged!(_videoController!.value.position);
//       }
//     }
//   }
//
//   void play() {
//     _videoController?.play();
//   }
//
//   void pause() {
//     _videoController?.pause();
//   }
//
//   void seekTo(Duration position) {
//     _videoController?.seekTo(position);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_hasError) {
//       return Container(
//         color: Colors.black,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               const Icon(
//                 Icons.error_outline,
//                 color: Colors.red,
//                 size: 60,
//               ),
//               const SizedBox(height: 16),
//               const Text(
//                 'Failed to load video',
//                 style: TextStyle(color: Colors.white, fontSize: 16),
//               ),
//               if (_errorMessage != null) ...[
//                 const SizedBox(height: 8),
//                 Text(
//                   _errorMessage!,
//                   style: const TextStyle(color: Colors.grey, fontSize: 12),
//                   textAlign: TextAlign.center,
//                 ),
//               ],
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (!_isInitialized || _chewieController == null) {
//       return Container(
//         color: Colors.black,
//         child: const Center(
//           child: CircularProgressIndicator(
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//           ),
//         ),
//       );
//     }
//
//     return Container(
//       color: Colors.black,
//       child: Center(
//         child: AspectRatio(
//           aspectRatio: _videoController!.value.aspectRatio,
//           child: Chewie(controller: _chewieController!),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _videoController?.removeListener(_videoListener);
//     _chewieController?.dispose();
//     _videoController?.dispose();
//     super.dispose();
//   }
// }
//
// // Image Viewer Widget
// class ImageView extends StatelessWidget {
//   final String? filePath;
//   final String? url;
//   final BoxFit fit;
//
//   const ImageView({
//     Key? key,
//     this.filePath,
//     this.url,
//     this.fit = BoxFit.contain,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     if (filePath != null && filePath!.isNotEmpty) {
//       return Image.file(
//         File(filePath!),
//         fit: fit,
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             color: Colors.black,
//             child: const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.broken_image, color: Colors.grey, size: 60),
//                   SizedBox(height: 16),
//                   Text(
//                     'Failed to load image',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     } else if (url != null && url!.isNotEmpty) {
//       return Image.network(
//         url!,
//         fit: fit,
//         loadingBuilder: (context, child, loadingProgress) {
//           if (loadingProgress == null) return child;
//           return Container(
//             color: Colors.black,
//             child: Center(
//               child: CircularProgressIndicator(
//                 value: loadingProgress.expectedTotalBytes != null
//                     ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                     : null,
//                 valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
//               ),
//             ),
//           );
//         },
//         errorBuilder: (context, error, stackTrace) {
//           return Container(
//             color: Colors.black,
//             child: const Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Icon(Icons.broken_image, color: Colors.grey, size: 60),
//                   SizedBox(height: 16),
//                   Text(
//                     'Failed to load image',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       );
//     }
//
//     return Container(
//       color: Colors.black,
//       child: const Center(
//         child: Text(
//           'No image source provided',
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
//
// // Enhanced Video Player Screen with better resource management
// class VideoPlayerScreen extends StatefulWidget {
//   final List<MediaItem> videoItems;
//   final int index;
//   final Function(int)? onIndexChanged;
//
//   const VideoPlayerScreen({
//     Key? key,
//     required this.videoItems,
//     this.index = 0,
//     this.onIndexChanged,
//   }) : super(key: key);
//
//   @override
//   State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
// }
//
// class _VideoPlayerScreenState extends State<VideoPlayerScreen> with TickerProviderStateMixin {
//   CarouselSliderController carouselController = CarouselSliderController();
//   late Box<VideoSettings> settingsBox;
//   late VideoSettings currentSettings;
//
//   int currentIndex = 0;
//   Map<int, EnhancedVideoPlayer> videoPlayers = {};
//   bool isInitialized = false;
//
//   // Animation controller for transitions
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnimation;
//
//   final List<SlideTransform> transitions = [
//     const AccordionTransform(),
//     const BackgroundToForegroundTransform(),
//     const ForegroundToBackgroundTransform(),
//     const DefaultTransform(),
//     const FlipHorizontalTransform(),
//     const ParallaxTransform(),
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeSettings();
//     currentIndex = widget.index;
//
//     _fadeController = AnimationController(
//       duration: const Duration(milliseconds: 300),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(
//       begin: 0.0,
//       end: 1.0,
//     ).animate(CurvedAnimation(
//       parent: _fadeController,
//       curve: Curves.easeInOut,
//     ));
//
//     _initializeCurrentAndAdjacentItems();
//   }
//
//   void _initializeSettings() {
//     try {
//       settingsBox = Hive.box<VideoSettings>('video_settings');
//       currentSettings = settingsBox.getAt(0) ?? VideoSettings();
//     } catch (e) {
//       currentSettings = VideoSettings();
//     }
//   }
//
//   Future<void> _initializeCurrentAndAdjacentItems() async {
//     final indicesToLoad = _getIndicesToLoad();
//
//     for (var index in indicesToLoad) {
//       if (!videoPlayers.containsKey(index) && widget.videoItems[index].type == 'video') {
//         await _createVideoPlayer(index);
//       }
//     }
//
//     if (mounted) {
//       setState(() {
//         isInitialized = true;
//       });
//       _fadeController.forward();
//     }
//   }
//
//   List<int> _getIndicesToLoad() {
//     final indices = <int>[];
//     final totalItems = widget.videoItems.length;
//
//     // Load current, previous, and next items
//     final prev = (currentIndex - 1 + totalItems) % totalItems;
//     final next = (currentIndex + 1) % totalItems;
//
//     indices.addAll([prev, currentIndex, next]);
//     return indices.toSet().toList(); // Remove duplicates
//   }
//
//   Future<void> _createVideoPlayer(int index) async {
//     final item = widget.videoItems[index];
//
//     if (item.type == "video") {
//       final videoPlayer = EnhancedVideoPlayer(
//         mediaItem: item,
//         // settings: currentSettings,
//         autoPlay: index == currentIndex,
//         onVideoEnded: () => _onVideoEnded(index),
//         onVideoStarted: () => _onVideoStarted(index),
//         onPositionChanged: (position) => _onPositionChanged(index, position),
//       );
//
//       videoPlayers[index] = videoPlayer;
//     }
//   }
//
//   void _onVideoEnded(int index) {
//     print('Video at index $index ended');
//     // Auto-advance to next item if current video ends
//     // if (index == currentIndex && !currentSettings.looping) {
//     //   _goToNext();
//     // }
//   }
//
//   void _onVideoStarted(int index) {
//     print('Video at index $index started');
//   }
//
//   void _onPositionChanged(int index, Duration position) {
//     // Handle position updates for analytics or progress tracking
//   }
//
//   void _onPageChanged(int index) async {
//     if (!mounted) return;
//
//     setState(() {
//       currentIndex = index;
//     });
//
//     // Notify parent widget of index change
//     if (widget.onIndexChanged != null) {
//       widget.onIndexChanged!(index);
//     }
//
//     // Initialize new adjacent items
//     await _initializeCurrentAndAdjacentItems();
//
//     // Cleanup unused controllers
//     _cleanupUnusedPlayers();
//   }
//
//   void _cleanupUnusedPlayers() {
//     final indicesToKeep = _getIndicesToLoad();
//     final keysToRemove = videoPlayers.keys.where((k) => !indicesToKeep.contains(k)).toList();
//
//     for (var key in keysToRemove) {
//       videoPlayers.remove(key);
//     }
//   }
//
//   void _goToNext() {
//     carouselController.nextPage();
//   }
//
//   void _goToPrevious() {
//     carouselController.previousPage();
//   }
//
//   void _togglePlayPause() {
//     if (videoPlayers.containsKey(currentIndex)) {
//       final currentItem = widget.videoItems[currentIndex];
//       if (currentItem.type == 'video') {
//         // Access the video player and toggle play/pause
//         // This would require exposing methods from EnhancedVideoPlayer
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Main carousel
//             FadeTransition(
//               opacity: _fadeAnimation,
//               child: CarouselSlider.builder(
//                 controller: carouselController,
//                 slideTransform: transitions[currentIndex % transitions.length],
//                 enableAutoSlider: true,
//                 autoSliderDelay: Duration(seconds: int.parse(widget.videoItems[currentIndex].timer.toString())),
//                 itemCount: widget.videoItems.length,
//                 slideBuilder: (index) {
//                   final item = widget.videoItems[index];
//
//                   if (item.type == 'image') {
//                     return ImageView(
//                       filePath: item.localPath,
//                       url: item.url,
//                       fit: BoxFit.contain,
//                     );
//                   } else if (item.type == 'video') {
//                     if (!videoPlayers.containsKey(index)) {
//                       return Container(
//                         color: Colors.black,
//                         child: const Center(
//                           child: CircularProgressIndicator(
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         ),
//                       );
//                     }
//                     return videoPlayers[index]!;
//                   }
//
//                   return Container(
//                     color: Colors.black,
//                     child: const Center(
//                       child: Text(
//                         'Unsupported media type',
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
//                   );
//                 },
//                 onSlideChanged: _onPageChanged,
//               ),
//             ),
//
//
//             // Media info overlay
//             Positioned(
//               top: 20,
//               left: 20,
//               right: 20,
//               child: Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.7),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     if (widget.videoItems[currentIndex].title != null)
//                       Text(
//                         widget.videoItems[currentIndex].title!,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontSize: 18,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     // if (widget.videoItems[currentIndex].description != null) ...[
//                     //   const SizedBox(height: 8),
//                     //   Text(
//                     //     widget.videoItems[currentIndex].description!,
//                     //     style: const TextStyle(
//                     //       color: Colors.white70,
//                     //       fontSize: 14,
//                     //     ),
//                     //   ),
//                     // ],
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     _fadeController.dispose();
//     videoPlayers.clear();
//     super.dispose();
//   }
// }
//
// // Video Player Manager - Singleton for global video management
// class VideoPlayerManager {
//   static final VideoPlayerManager _instance = VideoPlayerManager._internal();
//   factory VideoPlayerManager() => _instance;
//   VideoPlayerManager._internal();
//
//   final Map<String, VideoPlayerController> _globalControllers = {};
//
//   Future<VideoPlayerController> getController(String source, {bool isFile = true}) async {
//     if (_globalControllers.containsKey(source)) {
//       return _globalControllers[source]!;
//     }
//
//     final controller = isFile
//         ? VideoPlayerController.file(File(source))
//         : VideoPlayerController.networkUrl(Uri.parse(source));
//
//     await controller.initialize();
//     _globalControllers[source] = controller;
//
//     return controller;
//   }
//
//   void disposeController(String source) {
//     _globalControllers[source]?.dispose();
//     _globalControllers.remove(source);
//   }
//
//   void disposeAll() {
//     for (var controller in _globalControllers.values) {
//       controller.dispose();
//     }
//     _globalControllers.clear();
//   }
// }
// // Utility functions for video management
// class VideoUtils {
//   static Duration parseDuration(String duration) {
//     final parts = duration.split(':');
//     if (parts.length == 2) {
//       return Duration(
//         minutes: int.parse(parts[0]),
//         seconds: int.parse(parts[1]),
//       );
//     } else if (parts.length == 3) {
//       return Duration(
//         hours: int.parse(parts[0]),
//         minutes: int.parse(parts[1]),
//         seconds: int.parse(parts[2]),
//       );
//     }
//     return Duration.zero;
//   }
//
//   static String formatDuration(Duration duration) {
//     final hours = duration.inHours;
//     final minutes = duration.inMinutes.remainder(60);
//     final seconds = duration.inSeconds.remainder(60);
//
//     if (hours > 0) {
//       return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//     } else {
//       return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
//     }
//   }
//
//   static Future<bool> isVideoFile(String path) async {
//     final file = File(path);
//     if (!await file.exists()) return false;
//
//     final extension = path.toLowerCase().split('.').last;
//     const videoExtensions = ['mp4', 'avi', 'mov', 'mkv', 'flv', 'wmv', 'm4v'];
//
//     return videoExtensions.contains(extension);
//   }
//
//   static Future<bool> isImageFile(String path) async {
//     final file = File(path);
//     if (!await file.exists()) return false;
//
//     final extension = path.toLowerCase().split('.').last;
//     const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'];
//
//     return imageExtensions.contains(extension);
//   }
// }
