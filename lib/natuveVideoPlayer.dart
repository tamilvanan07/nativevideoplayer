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
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    _disposeController();
    super.dispose();
  }

  Future<void> _disposeController() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height,
      child: AndroidView(
        viewType: viewType,
        onPlatformViewCreated: (int id) {
          if (_isDisposed) return;

          print("VIEW ID: $id, Path: ${widget.path}");

          MediaPlayerService.onPlatformViewCreated(id, (controller) async {
            if (_isDisposed) {
              controller.dispose();
              return;
            }

            if (mounted) {
              setState(() {
                _controller = controller;
              });
            }

            // Set up completion listener
            _controller!.onCompletion = () {
              print("Video playback completed");
              if (!_isDisposed && mounted) {
                _disposeController();
              }
            };

            // Set up error listener
            _controller!.onError = (message) {
              print("Video error: $message");
              if (!_isDisposed && mounted) {
                _disposeController();
              }
            };

            // Load and play video
            try {
              var res = await _controller?.loadVideo(widget.path ?? "");
              print("Load video response: $res");

              if (res == 'success' && !_isDisposed) {
                await _controller?.play();
              }
            } catch (e) {
              print("Error loading/playing video: $e");
              if (!_isDisposed && mounted) {
                _disposeController();
              }
            }
          });
        },
        creationParamsCodec: const StandardMessageCodec(),
      ),
    );
  }
}
