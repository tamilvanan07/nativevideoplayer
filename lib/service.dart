import 'package:flutter/services.dart';

class VideoPlayerService {
  static const MethodChannel _channel = MethodChannel('video_player');

  // Initialize the video player
  static Future<bool> initializePlayer() async {
    try {
      final result = await _channel.invokeMethod('initializePlayer');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to initialize player: '${e.message}'.");
      return false;
    }
  }

  // Load video from URL
  static Future<bool> loadVideo(String videoUrl) async {
    try {
      final result = await _channel.invokeMethod('loadVideo', {
        'url': videoUrl,
      });
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to load video: '${e.message}'.");
      return false;
    }
  }

  // Play video
  static Future<bool> play() async {
    try {
      final result = await _channel.invokeMethod('play');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to play video: '${e.message}'.");
      return false;
    }
  }

  // Pause video
  static Future<bool> pause() async {
    try {
      final result = await _channel.invokeMethod('pause');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to pause video: '${e.message}'.");
      return false;
    }
  }

  // Stop video
  static Future<bool> stop() async {
    try {
      final result = await _channel.invokeMethod('stop');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to stop video: '${e.message}'.");
      return false;
    }
  }

  // Seek to position (in milliseconds)
  static Future<bool> seekTo(int positionMs) async {
    try {
      final result = await _channel.invokeMethod('seekTo', {
        'position': positionMs,
      });
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to seek: '${e.message}'.");
      return false;
    }
  }

  // Get current position
  static Future<int> getCurrentPosition() async {
    try {
      final result = await _channel.invokeMethod('getCurrentPosition');
      return result as int;
    } on PlatformException catch (e) {
      print("Failed to get position: '${e.message}'.");
      return 0;
    }
  }

  // Get duration
  static Future<int> getDuration() async {
    try {
      final result = await _channel.invokeMethod('getDuration');
      return result as int;
    } on PlatformException catch (e) {
      print("Failed to get duration: '${e.message}'.");
      return 0;
    }
  }

  // Check if playing
  static Future<bool> isPlaying() async {
    try {
      final result = await _channel.invokeMethod('isPlaying');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to check playing status: '${e.message}'.");
      return false;
    }
  }

  // Set volume (0.0 to 1.0)
  static Future<bool> setVolume(double volume) async {
    try {
      final result = await _channel.invokeMethod('setVolume', {
        'volume': volume,
      });
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to set volume: '${e.message}'.");
      return false;
    }
  }

  // Show native player UI
  static Future<bool> showPlayerUI() async {
    try {
      final result = await _channel.invokeMethod('showPlayerUI');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to show player UI: '${e.message}'.");
      return false;
    }
  }

  // Hide native player UI
  static Future<bool> hidePlayerUI() async {
    try {
      final result = await _channel.invokeMethod('hidePlayerUI');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to hide player UI: '${e.message}'.");
      return false;
    }
  }

  // Dispose player
  static Future<bool> disposePlayer() async {
    try {
      final result = await _channel.invokeMethod('disposePlayer');
      return result as bool;
    } on PlatformException catch (e) {
      print("Failed to dispose player: '${e.message}'.");
      return false;
    }
  }
}