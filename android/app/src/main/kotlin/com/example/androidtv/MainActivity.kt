package com.example.androidtv

import android.R.attr.id
import android.media.MediaPlayer
import android.os.Handler
import android.os.Looper
import com.example.nativetvflutter.NativePlayerViewFactory
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example/native_player"
    private var mediaPlayer: MediaPlayer? = null
    private var methodChannel: MethodChannel? = null
    private val handler = Handler(Looper.getMainLooper())

    private var results:  MethodChannel.Result? = null

    lateinit var nativeViewFactory: NativePlayerViewFactory
    private var progressRunnable: Runnable? = null

    private val SEEK_TIME_MS = 10000


    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        nativeViewFactory = NativePlayerViewFactory(
            flutterEngine.dartExecutor.binaryMessenger, this
        )

        flutterEngine.platformViewsController.registry.registerViewFactory("videoPlayer", nativeViewFactory)

        
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)


        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "loadVideo" -> {
                    val url = call.argument<String>("url")
                    if (url != null) {
                        // Check if the surface is already created before loading
                        if (nativeViewFactory.nativePlayerView?.surfaceView?.holder?.surface?.isValid ?: false) {
                            nativeViewFactory.nativePlayerView?.loadVideo(url)
                        }
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing 'url' parameter.", null)
                    }
                }
                "play" -> {
                    // 1. PLAY: Check if the player is prepared and not currently playing
                    if (mediaPlayer?.isPlaying == false) {
                        mediaPlayer?.start()
                    }
                    result.success(true)
                }
                "pause" -> {
                    // 2. PAUSE
                    mediaPlayer?.pause()
                    result.success(true)
                }
                "forward" -> {
                    // 3. FORWARD (Seek Forward)
                    val currentPosition = mediaPlayer?.currentPosition ?: 0
                    val duration = mediaPlayer?.duration ?: 0

                    var newPosition = currentPosition + SEEK_TIME_MS
                    if ((newPosition) > duration) {
                        newPosition = duration
                    }

                    mediaPlayer?.seekTo(newPosition)
                    result.success(true)
                }

                "dispose" -> {
                    // Dispose the MediaPlayer when done
                    mediaPlayer?.release()
                    mediaPlayer = null
                    result.success(true)
                }
                "backward" -> {
                    // 4. BACKWARD (Seek Backward)
                    val currentPosition = mediaPlayer?.currentPosition ?: 0

                    var newPosition = currentPosition - SEEK_TIME_MS
                    if (newPosition < 0) {
                        newPosition = 0
                    }

                    mediaPlayer?.seekTo(newPosition)
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    // Method to send data (ensure eventSink is not null)
    fun sendFrameData(data: Any) {
        handler.post{
            results?.success(data)// Ensure this is never null
        }
    }

    private fun initializePlayer(videoUrl: String, result: MethodChannel.Result) {
        try {
            releasePlayer()
            
            mediaPlayer = MediaPlayer().apply {
                setDataSource(videoUrl)
                setOnPreparedListener { mp ->
                    val duration = mp.duration
                    methodChannel?.invokeMethod("onDurationChanged", mapOf("duration" to duration))
                    result.success(true)
                }
                setOnErrorListener { _, what, extra ->
                    val errorMsg = "MediaPlayer error: what=$what, extra=$extra"
                    methodChannel?.invokeMethod("onError", mapOf("message" to errorMsg))
                    true
                }
                setOnCompletionListener {
                    stopProgressUpdates()
                    methodChannel?.invokeMethod("onPlaybackStateChanged", mapOf("isPlaying" to false))
                }
                prepareAsync()
            }
        } catch (e: Exception) {
            result.error("PLAYER_ERROR", "Failed to initialize player: ${e.message}", null)
        }
    }

    private fun play(result: MethodChannel.Result) {
        try {
            mediaPlayer?.let { mp ->
                if (!mp.isPlaying) {
                    mp.start()
                    startProgressUpdates()
                    methodChannel?.invokeMethod("onPlaybackStateChanged", mapOf("isPlaying" to true))
                    result.success(true)
                } else {
                    result.error("ALREADY_PLAYING", "Player is already playing", null)
                }
            } ?: result.error("NO_PLAYER", "Player not initialized", null)
        } catch (e: Exception) {
            result.error("PLAY_ERROR", "Failed to play: ${e.message}", null)
        }
    }

    private fun pause(result: MethodChannel.Result) {
        try {
            mediaPlayer?.let { mp ->
                if (mp.isPlaying) {
                    mp.pause()
                    stopProgressUpdates()
                    methodChannel?.invokeMethod("onPlaybackStateChanged", mapOf("isPlaying" to false))
                    result.success(true)
                } else {
                    result.error("NOT_PLAYING", "Player is not playing", null)
                }
            } ?: result.error("NO_PLAYER", "Player not initialized", null)
        } catch (e: Exception) {
            result.error("PAUSE_ERROR", "Failed to pause: ${e.message}", null)
        }
    }

    private fun stop(result: MethodChannel.Result) {
        try {
            mediaPlayer?.let { mp ->
                mp.stop()
                mp.prepareAsync()
                stopProgressUpdates()
                methodChannel?.invokeMethod("onPlaybackStateChanged", mapOf("isPlaying" to false))
                methodChannel?.invokeMethod("onPositionChanged", mapOf("position" to 0))
                result.success(true)
            } ?: result.error("NO_PLAYER", "Player not initialized", null)
        } catch (e: Exception) {
            result.error("STOP_ERROR", "Failed to stop: ${e.message}", null)
        }
    }

    private fun seekTo(position: Int, result: MethodChannel.Result) {
        try {
            mediaPlayer?.let { mp ->
                mp.seekTo(position)
                methodChannel?.invokeMethod("onPositionChanged", mapOf("position" to position))
                result.success(true)
            } ?: result.error("NO_PLAYER", "Player not initialized", null)
        } catch (e: Exception) {
            result.error("SEEK_ERROR", "Failed to seek: ${e.message}", null)
        }
    }

    private fun startProgressUpdates() {
        progressRunnable = object : Runnable {
            override fun run() {
                mediaPlayer?.let { mp ->
                    if (mp.isPlaying) {
                        val currentPosition = mp.currentPosition
                        methodChannel?.invokeMethod("onPositionChanged", 
                            mapOf("position" to currentPosition))
                        handler.postDelayed(this, 500) // Update every 500ms
                    }
                }
            }
        }
        handler.post(progressRunnable!!)
    }

    private fun stopProgressUpdates() {
        progressRunnable?.let { handler.removeCallbacks(it) }
        progressRunnable = null
    }

    private fun releasePlayer() {
        stopProgressUpdates()
        mediaPlayer?.release()
        mediaPlayer = null
    }

    override fun onDestroy() {
        releasePlayer()
        super.onDestroy()
    }
}
