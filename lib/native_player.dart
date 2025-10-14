import 'package:androidtv/service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  bool _isPlaying = false;
  bool _isInitialized = false;
  int _currentPosition = 0;
  int _duration = 0;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final initialized = await VideoPlayerService.initializePlayer();
    if (initialized) {
      final loaded = await VideoPlayerService.loadVideo(widget.videoUrl);
      if (loaded) {
        setState(() {
          _isInitialized = true;
        });
        _updatePlayerState();
      }
    }
  }

  Future<void> _updatePlayerState() async {
    if (!mounted) return;

    final position = await VideoPlayerService.getCurrentPosition();
    final duration = await VideoPlayerService.getDuration();
    final playing = await VideoPlayerService.isPlaying();

    setState(() {
      _currentPosition = position;
      _duration = duration;
      _isPlaying = playing;
    });

    // Update every second if playing
    if (_isPlaying) {
      Future.delayed(const Duration(seconds: 1), _updatePlayerState);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await VideoPlayerService.pause();
    } else {
      await VideoPlayerService.play();
    }
    _updatePlayerState();
  }

  String _formatDuration(int milliseconds) {
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    VideoPlayerService.disposePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Material(
      child: Column(
        children: [
          // Native player container (handled by native side)
          Container(
            height: 200,
            width: double.infinity,
            color: Colors.black,
            child: const Center(
              child: Text(
                'Native Video Player\n(Rendered by native code)',
                style: TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      
          // Flutter controls
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Progress bar
                Slider(
                  value: _duration > 0 ? _currentPosition / _duration : 0.0,
                  onChanged: (value) {
                    final position = (value * _duration).toInt();
                    VideoPlayerService.seekTo(position);
                  },
                  min: 0.0,
                  max: 1.0,
                ),
      
                // Time display
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_currentPosition)),
                    Text(_formatDuration(_duration)),
                  ],
                ),
      
                const SizedBox(height: 16),
      
                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () => VideoPlayerService.seekTo(0),
                      icon: const Icon(Icons.skip_previous),
                    ),
                    IconButton(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                    ),
                    IconButton(
                      onPressed: () => VideoPlayerService.stop(),
                      icon: const Icon(Icons.stop),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
