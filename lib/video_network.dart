import 'package:flutter/material.dart';

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/services.dart';

class VideoNetwork extends StatefulWidget {
  final String source;
  final bool isNetwork; // true = network URL, false = local file path
  final bool looping;

  const VideoNetwork({
    super.key,
    required this.source,
    this.isNetwork = true,
    this.looping = false,
  });

  @override
  State<VideoNetwork> createState() => _VideoNetworkState();
}

class _VideoNetworkState extends State<VideoNetwork> {
  late VideoPlayerController _controller;
  bool _initialized = false;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    _controller = widget.isNetwork
        ? VideoPlayerController.networkUrl(Uri.parse(widget.source))
        : VideoPlayerController.file(File(widget.source));

    _controller.setLooping(widget.looping);

    _controller.addListener(() {
      final bool buffering = _controller.value.isBuffering;
      if (buffering != _isBuffering) {
        setState(() => _isBuffering = buffering);
      }
      if (_controller.value.hasError) {
        // Optionally handle errors here
      }
    });

    try {
      await _controller.initialize();
      setState(() => _initialized = true);
    } catch (_) {
      // initialization failed
      setState(() => _initialized = false);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(() {});
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = d.inHours;
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _togglePlay() {
    if (!_initialized) return;
    setState(() {
      _controller.value.isPlaying ? _controller.pause() : _controller.play();
    });
  }

  Future<void> _enterFullScreen() async {
    if (!_initialized) return;
    final wasPlaying = _controller.value.isPlaying;
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (_, __, ___) => _FullScreenVideo(controller: _controller),
      ),
    );
    // After full screen, restore play state if needed
    if (wasPlaying && !_controller.value.isPlaying) {
      _controller.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AspectRatio(
        aspectRatio: _initialized ? _controller.value.aspectRatio : 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_initialized)
              VideoPlayer(_controller)
            else
              const Center(child: CircularProgressIndicator()),
            if (_isBuffering) const Center(child: CircularProgressIndicator()),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildControls(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final position = _initialized ? _controller.value.position : Duration.zero;
    final duration = _initialized ? _controller.value.duration : Duration.zero;
    final isPlaying = _initialized && _controller.value.isPlaying;

    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                color: Colors.white,
                onPressed: _togglePlay,
              ),
              Text(
                _formatDuration(position),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              Expanded(
                child: Slider(
                  activeColor: Colors.redAccent,
                  inactiveColor: Colors.white24,
                  min: 0,
                  max: duration.inMilliseconds.toDouble().clamp(
                    0.1,
                    double.infinity,
                  ),
                  value: position.inMilliseconds.toDouble().clamp(
                    0.0,
                    duration.inMilliseconds.toDouble().clamp(
                      0.0,
                      double.infinity,
                    ),
                  ),
                  onChanged: (v) {
                    if (!_initialized) return;
                    _controller.seekTo(Duration(milliseconds: v.round()));
                  },
                  onChangeEnd: (v) {
                    if (!_initialized) return;
                    _controller.seekTo(Duration(milliseconds: v.round()));
                  },
                ),
              ),
              Text(
                _formatDuration(duration),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                color: Colors.white,
                onPressed: _enterFullScreen,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FullScreenVideo extends StatefulWidget {
  final VideoPlayerController controller;
  const _FullScreenVideo({required this.controller});

  @override
  State<_FullScreenVideo> createState() => _FullScreenVideoState();
}

class _FullScreenVideoState extends State<_FullScreenVideo> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: controller.value.isInitialized
            ? GestureDetector(
                onTap: () {
                  // tap to toggle play/pause
                  controller.value.isPlaying
                      ? controller.pause()
                      : controller.play();
                  setState(() {});
                },
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
