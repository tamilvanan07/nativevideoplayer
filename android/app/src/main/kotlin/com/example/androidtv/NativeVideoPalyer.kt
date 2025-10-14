package com.example.nativetvflutter

import android.content.Context
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import android.media.MediaPlayer // Import MediaPlayer
import android.net.Uri
import android.view.SurfaceHolder // Import SurfaceHolder for SurfaceView
import android.view.SurfaceView // Import SurfaceView to display the video
import android.view.View
import android.widget.FrameLayout
import android.widget.MediaController
import android.widget.VideoView

import androidx.core.net.toUri
import com.example.androidtv.MainActivity


/**
 * A factory that creates new instances of the NativePlayerView when Flutter requests one.
 * It's registered in MainActivity.kt with the unique viewType ID.
 *
 * @param messenger A BinaryMessenger to create MethodChannels for communication.
 */

class NativePlayerViewFactory(private val messenger: BinaryMessenger,val mainActivity: MainActivity) :
    PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    var nativePlayerView: NativePlayerView? = null

    /**
     * Called by Flutter to create the native Android View object.
     *
     * @param context The Android context (usually the Activity)
     * @param viewId A unique identifier for this specific view instance.
     * @param args Optional arguments passed from the Flutter side (e.g., the initial video URL).
     * @return A new instance of your native view (which must implement PlatformView).
     */
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        // Cast the arguments to a Map if they were provided from Flutter
        val creationParams = args as Map<*, *>?
        nativePlayerView = NativePlayerView(context, messenger, viewId, mainActivity,creationParams)

        // Create and return your NativePlayerView, passing the necessary components
        return nativePlayerView!!
    }
}




class NativePlayerView(
    private val context: Context,
    messenger: BinaryMessenger,
    id: Int,
    private val mainActivity: MainActivity,
    creationParams: Map<*, *>?
) : PlatformView,
    SurfaceHolder.Callback, // Required for SurfaceView lifecycle
    MediaPlayer.OnPreparedListener // Required for asynchronous loading
{

    private val rootView: FrameLayout
    val surfaceView: SurfaceView
    private var mediaPlayer: MediaPlayer? = null
    private var videoUrl: String? = null

    // Define a constant for seek time (e.g., 10 seconds in milliseconds)
    private val SEEK_TIME_MS = 10000

    init {

        rootView = FrameLayout(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
        }

        // 1. Initialize the SurfaceView
        surfaceView = SurfaceView(context).apply {
            layoutParams = FrameLayout.LayoutParams(
                FrameLayout.LayoutParams.MATCH_PARENT,
                FrameLayout.LayoutParams.MATCH_PARENT
            )
            // Register this class as the callback for Surface events
            holder.addCallback(this@NativePlayerView)
        }
        rootView.addView(surfaceView)

        // 2. Initialize the MediaPlayer
        mediaPlayer = MediaPlayer().apply {
            setOnPreparedListener(this@NativePlayerView)
            setOnErrorListener { _, what, extra ->
                mainActivity.sendFrameData(mapOf("error" to "Media error: $what/$extra"))
                true
            }
        }
        mediaPlayer?.setOnPreparedListener(this)

        // Process creation parameters
        videoUrl = creationParams?.get("initialUrl") as? String
    }


    override fun getView(): View = rootView

// ----------------------------------------------------------------------
// MediaPlayer State Management
// ----------------------------------------------------------------------

    /**
     * Loads the video by setting the data source and preparing the player asynchronously.
     */

    fun onPause() {
        mediaPlayer?.pause()
    }

    fun onResume() {
        mediaPlayer?.start()
    }

     fun loadVideo(url: String) {
        videoUrl = url
        io.flutter.Log.e("URI","$videoUrl")
        mediaPlayer?.let { player ->
            try {
                // MediaPlayer must be reset before setting a new data source
                player.reset()
                player.setDataSource(url)
                // setDisplay must be called before prepare() or prepareAsync()
                player.setDisplay(surfaceView.holder)

                // Prepare the player in the background (critical for non-local files)
                player.prepareAsync()


                mainActivity.sendFrameData( player.isPlaying.toString())
            } catch (e: Exception) {
                mainActivity.sendFrameData( mapOf("message" to "Failed to load: ${e.message}"))
            }
        }
    }

    /**
     * Called when the MediaPlayer is ready to play.
     */
    override fun onPrepared(mp: MediaPlayer?) {
        mainActivity.sendFrameData("onLoading")
        // Auto-play is common, but you could skip this line if you want the Flutter side to call 'play()'
        mp?.start()
    }

// ----------------------------------------------------------------------
// SurfaceHolder.Callback Implementation
// ----------------------------------------------------------------------

    /**
     * Called immediately after the surface is first created.
     */
    override fun surfaceCreated(holder: SurfaceHolder) {
        // This is the ideal place to load and prepare the media source
        videoUrl?.let { url ->
            loadVideo(url)
        }
    }

    /**
     * Called after any changes have been made to the surface, such as format or size.
     */
// Inside your NativePlayerView class

    override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {
        // 1. Log the new dimensions for debugging
        io.flutter.Log.i("NativePlayerView", "Surface size changed to: $width x $height")

        // 2. (Optional but often useful) If you had a custom layout logic
        //    to maintain the video's aspect ratio (e.g., center-crop or fit),
        //    this is where you would call it:

        // setVideoSurfaceSize(width, height)

        // 3. For the standard MediaPlayer, if the video was paused and you
        //    wanted to ensure the display updates on resume:

         mediaPlayer?.let { player ->
             if (player.isPlaying) {
                 // No action usually required as the player continues rendering
             } else {
                 // Sometimes, a player needs a nudge to update its frame after a resize
//                 player.seekTo(player.currentPosition)
             }
         }
    }

    /**
     * Called immediately before a surface is being destroyed.
     */
    override fun surfaceDestroyed(holder: SurfaceHolder) {
        // Clean up the MediaPlayer
        mediaPlayer?.release()
        mediaPlayer = null
    }

// ----------------------------------------------------------------------
// MethodChannel.MethodCallHandler Implementation
// ----------------------------------------------------------------------



    override fun dispose() {
        // Release resources when the Flutter view is removed
        mediaPlayer?.release()
        mediaPlayer = null
    }
}
