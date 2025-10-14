import 'package:androidtv/logger/logger_file.dart';
import 'package:androidtv/natuveVideoPlayer.dart';
import 'package:androidtv/service/mediaService.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
// import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:hive/hive.dart';
import 'package:video_compress/video_compress.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

import '../db/media_time.dart';
import '../db/video_type.dart';
import 'enhance_player.dart';

// class CaroselViewWigdet extends StatefulWidget {
//   final List<MediaItem> videoItems;
//   const CaroselViewWigdet({super.key, required this.videoItems});
//
//   @override
//   State<CaroselViewWigdet> createState() => _CaroselViewWigdetState();
// }
//
// class _CaroselViewWigdetState extends State<CaroselViewWigdet> {
//   CarouselSliderController carouselController = CarouselSliderController();
//   late Box<VideoSettings> settingsBox;
//   late VideoSettings currentSettings;
//   int currentIndex = 0;
//   int playingIndex = 0;
//   bool allVideosLoaded = false;
//
//   void _onPageChanged(int index) {
//     setState(() {
//       currentIndex = index;
//     });
//   }
//
//   List<dynamic> transition = [
//     AccordionTransform(),
//     BackgroundToForegroundTransform(),
//     ForegroundToBackgroundTransform(),
//     DefaultTransform(),
//     FlipHorizontalTransform(),
//     ParallaxTransform(),
//   ];
//
//   @override
//   void initState() {
//     settingsBox = Hive.box<VideoSettings>('video_settings');
//     currentSettings = settingsBox.getAt(0) ?? VideoSettings();
//     carouselController.setAutoSliderEnabled(true);
//
//     super.initState();
//   }
//
//   String timer = "60";
//   @override
//   Widget build(BuildContext context) {
//     print("THE TIMER ${widget.videoItems[playingIndex].timer}");
//     return Center(
//       child: !allVideosLoaded
//           ? CarouselSlider.builder(
//               controller: carouselController,
//               slideTransform: transition[playingIndex % 2],
//               enableAutoSlider: true,
//               autoSliderDelay: Duration(
//                 // seconds: 10,
//                 seconds: int.parse('${widget.videoItems[playingIndex].timer}') ?? 0,
//               ),
//               itemCount: widget.videoItems.length,
//               slideBuilder: (int index) {
//                 playingIndex = index;
//                 return widget.videoItems[index].type == 'image'
//                     ? ImageView(filePath: widget.videoItems[index].localPath)
//                     : Container(
//                         color: Colors.black,
//                         child: Center(child: VideoView(filePath: widget.videoItems[index].localPath ?? "")),
//                       );
//               },
//               onSlideChanged: _onPageChanged,
//             )
//           : const Center(child: CircularProgressIndicator(color: Colors.white)),
//     );
//   }
// }
//
// class VideoView extends StatefulWidget {
//   final String filePath;
//   const VideoView({super.key, required this.filePath});
//
//   @override
//   State<VideoView> createState() => _VideoViewState();
// }
//
// class _VideoViewState extends State<VideoView> {
//   ChewieController? _chewieController;
//   late VideoPlayerController _videoPlayerController;
//   bool isLoading = true;
//
//   Future initFunc() async {
//     setState(() {
//       isLoading = true;
//     });
//     _videoPlayerController = VideoPlayerController.file(File(widget.filePath ?? ""));
//     // _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse('http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4'));
//     await _videoPlayerController.initialize();
//     _videoPlayerController.setLooping(false);
//
//     _videoPlayerController.addListener(() {
//       if (_videoPlayerController.value.position >= _videoPlayerController.value.duration &&
//           _videoPlayerController.value.duration > Duration.zero) {
//         _onVideoEnded();
//       }
//     });
//
//     setState(() {
//       isLoading = false;
//     });
//   }
//
//   void _onVideoEnded() {
//     Future.delayed(const Duration(milliseconds: 500), () {});
//   }
//
//   @override
//   void initState() {
//     initFunc().then((_) {
//       _chewieController = ChewieController(
//         videoPlayerController: _videoPlayerController,
//         autoPlay: true,
//         looping: false,
//         aspectRatio: _videoPlayerController.value.aspectRatio,
//         autoInitialize: true,
//         showControls: true,
//         allowFullScreen: true,
//         allowMuting: true,
//         showControlsOnInitialize: false,
//         hideControlsTimer: const Duration(seconds: 3),
//         materialProgressColors: ChewieProgressColors(
//           playedColor: Theme.of(context).primaryColor,
//           handleColor: Theme.of(context).primaryColor,
//           backgroundColor: Colors.grey,
//           bufferedColor: Colors.lightGreen,
//         ),
//       );
//     });
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _chewieController?.dispose();
//     _videoPlayerController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     print("REBUILD");
//     return Center(
//       child: _chewieController != null && _chewieController!.videoPlayerController.value.isInitialized
//           ? Chewie(controller: _chewieController!)
//           : const CircularProgressIndicator(color: Colors.white),
//     );
//   }
// }

class ImageView extends StatelessWidget {
  final String? filePath;
  const ImageView({super.key, this.filePath});

  @override
  Widget build(BuildContext context) {
    return Material(child: Image.file(File(filePath ?? ""), fit: BoxFit.cover));
  }
}

// Enhanced VideoPlayerScreen with proper codec support and error handling

class VideoPlayerScreenChiwe extends StatefulWidget {
  final List<MediaItem> videoItems;
  final int index;

  const VideoPlayerScreenChiwe({
    super.key,
    required this.videoItems,
    this.index = 0,
  });

  @override
  State<VideoPlayerScreenChiwe> createState() => _VideoPlayerScreenChiweState();
}

class _VideoPlayerScreenChiweState extends State<VideoPlayerScreenChiwe> {
  CarouselSliderController carouselController = CarouselSliderController();
  late Box<VideoSettings> settingsBox;
  late VideoSettings currentSettings;

  int currentIndex = 0;
  int selectedIndex = 0;
  Map<int, VideoPlayerController> videoControllers = {};
  // final Map<int, VlcPlayerController> _videoPlayerController = {};
  Map<int, ChewieController> chewieControllers = {};
  Map<int, bool> videoLoadingStates = {};
  Map<int, String?> videoErrors = {};
  bool allVideosLoaded = false;
  bool showCustomControls = false;

  // Supported video formats
  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
    'avi',
    'mkv',
    'webm',
    'flv',
    'm4v',
    '3gp',
  ];

  // Supported codecs (for reference)
  static const List<String> preferredCodecs = [
    'h264',
    'h265',
    'vp8',
    'vp9',
    'av1',
  ];

  static const String viewType = 'videoPlayer';

  @override
  void initState() {
    super.initState();
    settingsBox = Hive.box<VideoSettings>('video_settings');
    currentSettings = settingsBox.getAt(0) ?? VideoSettings();
    currentIndex = widget.index;
  }

  List<dynamic> transition = [
    AccordionTransform(),
    BackgroundToForegroundTransform(),
    ForegroundToBackgroundTransform(),
    DefaultTransform(),
    FlipHorizontalTransform(),
    ParallaxTransform(),
  ];

  final Map<int, MediaPlayerService> _players = {};

  void _onPageChanged(int index) {
    setState(() => currentIndex = index);

    // Pause all other videos
    _players.forEach((i, p) {
      if (i == index) {
        p.play();
      } else {
        p.pause();
      }
    });
  }

  // void _onPageChanged(int index) async {
  //   if (!mounted) return;

  //   // Pause current video before switching
  //   if (videoControllers.containsKey(currentIndex)) {
  //     videoControllers[currentIndex]?.pause();
  //   }

  //   setState(() {
  //     currentIndex = index;
  //   });

  //   if (widget.videoItems[index].type == 'video') {
  //     _playCurrentVideo();
  //   }
  // }

  void _onViewCreated(int id, int index) {
    MediaPlayerService.onPlatformViewCreated(id, (service) {
      _players[index] = service;
      service.loadVideo(widget.videoItems[index].localPath ?? "");
    });
  }

  // static const String viewType = 'videoPlayer';

  MediaPlayerService? _controller;

  @override
  void dispose() {
    for (final player in _players.values) {
      player.pause();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            CarouselSlider.builder(
              controller: carouselController,
              slideTransform: transition[currentIndex % transition.length],
              enableAutoSlider: true,
              autoSliderDelay: Duration(
                seconds: int.parse(
                  widget.videoItems[selectedIndex].timer.toString(),
                ),
              ),
              itemCount: widget.videoItems.length,
              slideBuilder: (index) {
                selectedIndex = index;
                final item = widget.videoItems[index];

                if (item.type == 'image') {
                  return ImageView(filePath: item.localPath);
                }
                // else {
                //   // Handle video loading states
                //   if (videoLoadingStates[index] == true) {
                //     return Container(
                //       color: Colors.black,
                //       child: const Center(
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             CircularProgressIndicator(color: Colors.white),
                //             SizedBox(height: 16),
                //             Text(
                //               'Loading video...',
                //               style: TextStyle(color: Colors.white),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   }

                //   // Handle video errors
                //   if (videoErrors[index] != null) {
                //     return Container(
                //       color: Colors.black,
                //       child: Center(
                //         child: Column(
                //           mainAxisAlignment: MainAxisAlignment.center,
                //           children: [
                //             const Icon(
                //               Icons.error_outline,
                //               color: Colors.red,
                //               size: 64,
                //             ),
                //             const SizedBox(height: 16),
                //             const Text(
                //               'Failed to load video',
                //               style: TextStyle(
                //                 color: Colors.white,
                //                 fontSize: 18,
                //               ),
                //             ),
                //             const SizedBox(height: 8),
                //             Text(
                //               videoErrors[index]!,
                //               style: const TextStyle(
                //                 color: Colors.grey,
                //                 fontSize: 14,
                //               ),
                //               textAlign: TextAlign.center,
                //             ),
                //             const SizedBox(height: 16),
                //             ElevatedButton(
                //               onPressed: () => _retryVideoInitialization(index),
                //               child: const Text('Retry'),
                //             ),
                //           ],
                //         ),
                //       ),
                //     );
                //   }

                return VideoCarouselItem(
                  playerId: index,
                  videoUrl: item.localPath ?? "",
                );

                // NativeVideoPlayer(path: item.localPath);

                //  SizedBox(
                //   height: MediaQuery.sizeOf(
                //     context,
                //   ).height, // Give the native view a fixed size
                //   child: AndroidView(
                //     viewType: viewType,
                //     // Callback when the native view is created and returns its ID
                //     onPlatformViewCreated: (int id) {
                //       print("VIEW ID ${item.localPath}");
                //       // Initialize the Dart controller with the unique ID
                //       MediaPlayerService.onPlatformViewCreated(id, (
                //         controller,
                //       ) async {
                //         setState(() {
                //           _controller = controller;
                //         });

                //         // Example: Automatically load a video when the view is ready
                //         var res = await _controller?.loadVideo(
                //           item.localPath ?? "",
                //         );

                //         print("RESPONSE $res");
                //       });
                //     },
                //     // The codec handles basic data types; necessary for Method Channels
                //     creationParamsCodec: const StandardMessageCodec(),
                //   ),
                // );

                // Chewie(controller: chewieControllers[index]!);
                // }
              },
              onSlideChanged: _onPageChanged,
            ),

            // Optional: Add debug info overlay in development
            if (kDebugMode)
              Positioned(
                top: 50,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Index: $currentIndex',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Controllers: ${videoControllers.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Type: ${widget.videoItems[currentIndex].type}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
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

  Widget _buildNativeView(int index) {
    return AndroidView(
      viewType: viewType,
      // Callback when the native view is created and returns its ID
      onPlatformViewCreated: (int id) {
        print("VIEW ID ${widget.videoItems[index].localPath}");
        // Initialize the Dart controller with the unique ID
        MediaPlayerService.onPlatformViewCreated(id, (controller) async {
          setState(() {
            _controller = controller;
          });

          // Example: Automatically load a video when the view is ready
          var res = await _controller?.loadVideo(
            widget.videoItems[index].localPath,
          );

          print("RESPONSE $res");
        });
      },
      // The codec handles basic data types; necessary for Method Channels
      creationParamsCodec: const StandardMessageCodec(),
    );

    // PlatformViewLink(
    //   viewType: viewType,
    //   onCreatePlatformView: (params) {
    //     final controller = PlatformViewsService.initSurfaceAndroidView(
    //       id: params.id,
    //       viewType: viewType,
    //       layoutDirection: TextDirection.ltr,
    //       creationParams: {'url': widget.videoItems[index].localPath ?? ""},
    //       creationParamsCodec: const StandardMessageCodec(),
    //     );

    //     controller.create();
    //     _onViewCreated(params.id, index);
    //     return controller;
    //   },
    //   surfaceFactory: (context, controller) {
    //     return AndroidViewSurface(
    //       controller: controller as AndroidViewController,
    //       gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
    //       hitTestBehavior: PlatformViewHitTestBehavior.opaque,
    //     );
    //   },
    // );
  }
}

// @override
// void dispose() {
//   // Properly dispose all controllers
//   for (var controller in chewieControllers.values) {
//     controller.dispose();
//   }
//   for (var controller in videoControllers.values) {
//     controller.dispose();
//   }
//   super.dispose();
// }

// Settings Dialog
class VideoSettingsDialog extends StatefulWidget {
  final VideoSettings currentSettings;
  final Function(VideoSettings) onSettingsChanged;

  const VideoSettingsDialog({
    super.key,
    required this.currentSettings,
    required this.onSettingsChanged,
  });

  @override
  State<VideoSettingsDialog> createState() => _VideoSettingsDialogState();
}

class _VideoSettingsDialogState extends State<VideoSettingsDialog> {
  late VideoSettings tempSettings;

  @override
  void initState() {
    super.initState();
    tempSettings = VideoSettings(
      playDuration: widget.currentSettings.playDuration,
      autoPlay: widget.currentSettings.autoPlay,
      volume: widget.currentSettings.volume,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Video Settings'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Play Duration Slider
          Text('Play Duration: ${tempSettings.playDuration}s'),
          Slider(
            value: tempSettings.playDuration.toDouble(),
            min: 3,
            max: 30,
            divisions: 27,
            onChanged: (value) {
              setState(() {
                tempSettings.playDuration = value.round();
              });
            },
          ),

          SizedBox(height: 16),

          // Volume Slider
          Text('Volume: ${(tempSettings.volume * 100).round()}%'),
          Slider(
            value: tempSettings.volume,
            min: 0,
            max: 1,
            onChanged: (value) {
              setState(() {
                tempSettings.volume = value;
              });
            },
          ),

          SizedBox(height: 16),

          // Auto Play Switch
          SwitchListTile(
            title: Text('Auto Play'),
            value: tempSettings.autoPlay,
            onChanged: (value) {
              setState(() {
                tempSettings.autoPlay = value;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onSettingsChanged(tempSettings);
            Navigator.pop(context);
          },
          child: Text('Save'),
        ),
      ],
    );
  }
}

const String CHANNEL_NAME_BASE = "com.example/native_player_";

// 2. This would be part of your Carousel Slider's build/state logic
class VideoCarouselItem extends StatelessWidget {
  // The unique ID for this specific player instance (e.g., the carousel index)
  final int playerId;
  final String videoUrl;

  const VideoCarouselItem({
    super.key,
    required this.playerId,
    required this.videoUrl,
  });

  // Method to get a reference to this player's channel
  MethodChannel get playerChannel =>
      MethodChannel('$CHANNEL_NAME_BASE$playerId');

  // Function to call a native method
  Future<void> loadNewVideo(String url) async {
    try {
      final String result = await playerChannel.invokeMethod('loadVideo', {
        'url': url,
      });
      print("Load successful: $result");
    } catch (e) {
      print("Failed to load video: $e");
    }
  }

  // Function to call 'play'
  Future<void> playVideo() async {
    await playerChannel.invokeMethod('play');
  }

  // Function to call 'pause'
  Future<void> pauseVideo() async {
    await playerChannel.invokeMethod('pause');
  }

  static const String viewType = 'videoPlayer';

  @override
  Widget build(BuildContext context) {
    // 3. Use the AndroidView widget to embed the native player.
    // The 'creationParams' map is how you send the 'initialUrl' and potentially other data.
    return AndroidView(
      viewType:
          viewType, // This must match the name registered in the Android ViewFactory
      onPlatformViewCreated: (int viewId) {
        // The 'viewId' returned here is the same 'id' you passed to the factory.
        // It should match 'playerId' if your logic is correct.
        print('Platform View $viewId created.');

        // When the slide becomes the primary/current one, you can call play:
        if (playerId == 0 /* Current active index */ ) {
          playVideo();
        }
      },
      // You can pass the initial URL here
      creationParams: <String, dynamic>{'initialUrl': videoUrl},
      creationParamsCodec: const StandardMessageCodec(),
    );
  }
}
