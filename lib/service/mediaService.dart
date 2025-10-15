import 'package:flutter/services.dart';

/// Service class to manage MediaPlayer through method channels
class MediaPlayerService {
  final MethodChannel _channel;
  // static const MethodChannel _channel = MethodChannel('com.example.mediaplayer/channel');

  bool _isDisposed = false;
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

  Future<String> loadVideo(String url) async {
    // Invoke the 'loadVideo' method with the 'url' parameter.
    var response = await _channel.invokeMethod('loadVideo', {'url': url});

    return response.toString();
  }

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

  Future<void> play() async {
    if (_isDisposed) return;
    try {
      // Invoke the simple 'play' method.
      return await _channel.invokeMethod('play');
    } on PlatformException catch (e) {
      onError?.call('Play failed: ${e.message}');
    }
    // Invoke the simple 'play' method.
  }

  Future<void> pause() async {
    // Invoke the simple 'pause' method.
    return _channel.invokeMethod('pause');
  }

  Future<void> forward() async {
    // Invoke the 'forward' method (will seek by the native 10 seconds).
    return _channel.invokeMethod('forward');
  }

  Future<void> backward() async {
    // Invoke the 'backward' method (will seek by the native 10 seconds).
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
  }
}

  // void _setupCallbacks() {
  //   _channel.setMethodCallHandler((call) async {
  //     switch (call.method) {
  //       case 'onPrepared':
  //         int duration = call.arguments['duration'] as int;
  //         onPrepared?.call(duration);
  //         break;
  //       case 'onPlaybackStateChanged':
  //         bool isPlaying = call.arguments['isPlaying'] as bool;
  //         onPlaybackStateChanged?.call(isPlaying);
  //         break;
  //       case 'onPositionChanged':
  //         int position = call.arguments['position'] as int;
  //         onPositionChanged?.call(position);
  //         break;
  //       case 'onCompletion':
  //         onCompletion?.call();
  //         break;
  //       case 'onError':
  //         String message = call.arguments['message'] as String;
  //         onError?.call(message);
  //         break;
  //       case 'onBufferingUpdate':
  //         int percent = call.arguments['percent'] as int;
  //         onBufferingUpdate?.call(percent);
  //         break;
  //     }
  //   });
  // }

  // /// Initialize the media player with a URL
  // Future<bool> initialize(String url) async {
  //   try {
  //     final result = await _channel.invokeMethod('initialize', {'url': url});
  //     return result != null;
  //   } on PlatformException catch (e) {
  //     onError?.call('Initialize failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Start playback
  // Future<bool> play() async {
  //   try {
  //     final result = await _channel.invokeMethod('play');
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Play failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Pause playback
  // Future<bool> pause() async {
  //   try {
  //     final result = await _channel.invokeMethod('pause');
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Pause failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Stop playback
  // Future<bool> stop() async {
  //   try {
  //     final result = await _channel.invokeMethod('stop');
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Stop failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Seek to a specific position in milliseconds
  // Future<bool> seekTo(int position) async {
  //   try {
  //     final result = await _channel.invokeMethod('seekTo', {
  //       'position': position,
  //     });
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Seek failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Set volume (0.0 to 1.0)
  // Future<bool> setVolume(double volume) async {
  //   try {
  //     final result = await _channel.invokeMethod('setVolume', {
  //       'volume': volume,
  //     });
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Set volume failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Set looping mode
  // Future<bool> setLooping(bool looping) async {
  //   try {
  //     final result = await _channel.invokeMethod('setLooping', {
  //       'looping': looping,
  //     });
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Set looping failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Get duration in milliseconds
  // Future<int?> getDuration() async {
  //   try {
  //     final result = await _channel.invokeMethod('getDuration');
  //     return result as int?;
  //   } on PlatformException catch (e) {
  //     onError?.call('Get duration failed: ${e.message}');
  //     return null;
  //   }
  // }

  // /// Get current position in milliseconds
  // Future<int?> getCurrentPosition() async {
  //   try {
  //     final result = await _channel.invokeMethod('getCurrentPosition');
  //     return result as int?;
  //   } on PlatformException catch (e) {
  //     onError?.call('Get position failed: ${e.message}');
  //     return null;
  //   }
  // }

  // /// Check if currently playing
  // Future<bool> isPlaying() async {
  //   try {
  //     final result = await _channel.invokeMethod('isPlaying');
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Get playing state failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Reset the player
  // Future<bool> reset() async {
  //   try {
  //     final result = await _channel.invokeMethod('reset');
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Reset failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Release the player resources
  // Future<bool> release() async {
  //   try {
  //     final result = await _channel.invokeMethod('release');
  //     return result as bool? ?? false;
  //   } on PlatformException catch (e) {
  //     onError?.call('Release failed: ${e.message}');
  //     return false;
  //   }
  // }

  // /// Format duration from milliseconds to MM:SS
  // static String formatDuration(int milliseconds) {
  //   final seconds = milliseconds ~/ 1000;
  //   final minutes = seconds ~/ 60;
  //   final remainingSeconds = seconds % 60;
  //   return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  // }
// }
