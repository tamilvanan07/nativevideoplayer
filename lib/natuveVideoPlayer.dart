import 'package:androidtv/service/mediaService.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NativeVideoPlayer extends StatefulWidget {
  final String? path;
  const NativeVideoPlayer({super.key, this.path});

  @override
  State<NativeVideoPlayer> createState() => _NativeVideoPlayerState();
}

class _NativeVideoPlayerState extends State<NativeVideoPlayer> {
  static const String viewType = 'videoPlayer';

  MediaPlayerService? _controller;

  @override
  void dispose() {
    // _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(
        context,
      ).height, // Give the native view a fixed size
      child: AndroidView(
        viewType: viewType,
        // Callback when the native view is created and returns its ID
        onPlatformViewCreated: (int id) {
          print("VIEW ID ${widget.path}");
          // Initialize the Dart controller with the unique ID
          MediaPlayerService.onPlatformViewCreated(id, (controller) async {
            setState(() {
              _controller = controller;
            });

            // Example: Automatically load a video when the view is ready
            var res = await _controller?.loadVideo(widget.path ?? "");

            print("RESPONSE $res");
          });
        },
        // The codec handles basic data types; necessary for Method Channels
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}

//  PlatformViewLink(
//         viewType: viewType,
//         // Callback when the native view is created and returns its ID
//         // The codec handles basic data types; necessary for Method Channels
//         surfaceFactory: (context, controller) {
//           return AndroidViewSurface(
//             controller: controller as AndroidViewController,
//             gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
//             hitTestBehavior: PlatformViewHitTestBehavior.opaque,
//           );
//         },
//         onCreatePlatformView: (PlatformViewCreationParams params) {
//           MediaPlayerService.onPlatformViewCreated(params.id, (service) {
//             service.onPrepared = (duration) {
//               print('Video ready, duration: $duration');
//             };
//             service.loadVideo(widget.path ?? "");
//           });
//           _currentController = PlatformViewsService.initSurfaceAndroidView(
//             id: params.id,
//             viewType: viewType,
//             layoutDirection: TextDirection.ltr,
//             creationParams: {'': 'https://example.com/video.mp4'},
//             creationParamsCodec: const StandardMessageCodec(),
//           )..create();
//           {
//             return _currentController!;
//           }
//         },
//       ),
