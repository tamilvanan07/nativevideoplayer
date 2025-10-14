// mediaService.dart
import 'package:flutter/services.dart';

/// Service class to manage MediaPlayer through method channels
class MediaPlayerService {
  final MethodChannel _channel;
  bool _isDisposed = false;

  // Use unique channel per view instance
  MediaPlayerService._(int id)
    : _channel = MethodChannel('com.example/native_player_$id') {
    _setupCallbacks();
  }

  static void onPlatformViewCreated(
    int id,
    Function(MediaPlayerService) onCreated,
  ) {
    onCreated(MediaPlayerService._(id));
  }

  // Callback functions
  Function(int duration)? onPrepared;
  Function(bool isPlaying)? onPlaybackStateChanged;
  Function(int position)? onPositionChanged;
  Function()? onCompletion;
  Function(String message)? onError;
  Function(int percent)? onBufferingUpdate;

  void _setupCallbacks() {
    _channel.setMethodCallHandler((call) async {
      if (_isDisposed) return;

      switch (call.method) {
        case 'onPrepared':
          int duration = call.arguments['duration'] as int;
          onPrepared?.call(duration);
          break;
        case 'onPlaybackStateChanged':
          bool isPlaying = call.arguments['isPlaying'] as bool;
          onPlaybackStateChanged?.call(isPlaying);
          break;
        case 'onPositionChanged':
          int position = call.arguments['position'] as int;
          onPositionChanged?.call(position);
          break;
        case 'onCompletion':
          onCompletion?.call();
          break;
        case 'onError':
          String message = call.arguments['message'] as String;
          onError?.call(message);
          break;
        case 'onBufferingUpdate':
          int percent = call.arguments['percent'] as int;
          onBufferingUpdate?.call(percent);
          break;
      }
    });
  }

  Future<String> loadVideo(String url) async {
    if (_isDisposed) return 'disposed';
    try {
      var response = await _channel.invokeMethod('loadVideo', {'url': url});
      return response.toString();
    } catch (e) {
      print('loadVideo error: $e');
      return 'error';
    }
  }

  Future<void> play() async {
    if (_isDisposed) return;
    return _channel.invokeMethod('play');
  }

  Future<void> pause() async {
    if (_isDisposed) return;
    return _channel.invokeMethod('pause');
  }

  Future<void> forward() async {
    if (_isDisposed) return;
    return _channel.invokeMethod('forward');
  }

  Future<void> backward() async {
    if (_isDisposed) return;
    return _channel.invokeMethod('backward');
  }

  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;

    try {
      await _channel.invokeMethod('dispose');
    } catch (e) {
      print('dispose error: $e');
    }

    // Clear all callbacks
    onPrepared = null;
    onPlaybackStateChanged = null;
    onPositionChanged = null;
    onCompletion = null;
    onError = null;
    onBufferingUpdate = null;
  }
}
