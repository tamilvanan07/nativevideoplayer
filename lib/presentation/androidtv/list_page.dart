import 'dart:io';

import 'package:androidtv/logger/logger_ui.dart';
import 'package:androidtv/video_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import '../../cheiwe_player.dart';
import '../../db/media_time.dart';
import '../../db/video_type.dart';
import '../../native_player.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({super.key});

  @override
  State<ListScreen> createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  late Box<MediaItem> mediaBox;
  late Box<VideoSettings> settingsBox;

  bool isLoading = false;
  bool _isfocusedVideop = false;
  bool _isLoggerOpen = false;
  bool _isNetworkVideoPlay = false;

  @override
  void initState() {
    // Listen for focus changes to update the UI.
    _focusNode1.addListener(() {
      setState(() {
        _isFocused = _focusNode1.hasFocus;
      });
    });

    _focusNode2.addListener(() {
      setState(() {
        _isfocusedVideop = _focusNode2.hasFocus;
      });
    });

    _focusNode3.addListener(() {
      setState(() {
        _isLoggerOpen = _focusNode3.hasFocus;
      });
    });

    _focusNode4.addListener(() {
      setState(() {
        _isNetworkVideoPlay = _focusNode4.hasFocus;
      });
    });

    _initializeHive();
    super.initState();
  }

  Future<void> _initializeHive() async {
    try {
      // Get or open media box
      if (Hive.isBoxOpen('media_items')) {
        mediaBox = Hive.box<MediaItem>('media_items');
      } else {
        mediaBox = await Hive.openBox<MediaItem>('media_items');
      }

      // Get or open settings box
      if (Hive.isBoxOpen('video_settings')) {
        settingsBox = Hive.box<VideoSettings>('video_settings');
      } else {
        settingsBox = await Hive.openBox<VideoSettings>('video_settings');
      }

      _initializeDefaultData();
    } catch (e) {
      print('Error initializing Hive: $e');
      // If there's still an error, try to get existing boxes
      try {
        mediaBox = Hive.box<MediaItem>('media_items');
        settingsBox = Hive.box<VideoSettings>('video_settings');
        _initializeDefaultData();
      } catch (e2) {
        print('Failed to get existing boxes: $e2');
      }
    }
  }

  Future<void> _initializeDefaultData() async {
    setState(() {
      isLoading = true;
    });
    // await mediaBox.clear();
    // Add sample data if box is empty

    if (mediaBox.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    final videoData = [
      {
        'id': 'video_1',
        'title': 'BigBuckBunny',
        'url':
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
        'type': 'video',
        'timer': '10',
      },
      {
        'id': 'video_2',
        'title': 'ElephantsDream',
        'url':
            'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
        'type': 'video',
        'timer': '10',
      },
      {
        'id': 'video_3',
        'title': 'ForBiggerBlazes',
        'url':
            'https://gleneagles.com/wp-content/uploads/sites/7/2020/02/Gleneagles_Weddings.mp4',
        'type': 'video',
        'timer': '10',
      },
      {
        'id': 'image_1',
        'title': 'Nature Image 1',
        'url': 'https://picsum.photos/800/600?random=1',
        'type': 'image',
        'timer': '10',
      },
      {
        'id': 'image_2',
        'title': 'Nature Image 2',
        'url': 'https://picsum.photos/800/600?random=2',
        'type': 'image',
        'timer': '10',
      },
      {
        'id': 'image_3',
        'title': 'Nature Image 3',
        'url': 'https://picsum.photos/800/600?random=3',
        'type': 'image',
        'timer': '10',
      },
    ];

    int index = 0;
    // Add videos
    for (var data in videoData) {
      if (data['type'] == 'video') {
        final file = await downloadImageFile(
          data['url'] as String,
          type: 'video',
          index: index,
        );
        print("THE VALUE URL ${file.path}");
        print("THE VIDEO URL ${data['url']}");

        final item = MediaItem(
          id: data['id'] as String,
          title: data['title'] as String,
          url: data['url'] as String,
          timer: data['timer'] as String,
          localPath: file.path,
          type: data['type'] as String,
          createdAt: DateTime.now(),
        );
        // item.save();
        await mediaBox.add(item);
      } else {
        // For images, we can use the same download function but with a different type
        final file = await downloadImageFile(
          data['url'] as String,
          type: 'image',
          index: index,
        );
        print("THE VALUE URL ${file.path}");
        print("THE IMAGE URL ${data['url']}");

        final item = MediaItem(
          id: data['id'] as String,
          title: data['title'] as String,
          timer: data['timer'] as String,
          url: data['url'] as String,
          localPath: file.path,
          type: data['type'] as String,
          createdAt: DateTime.now(),
        );
        // item.save();
        await mediaBox.add(item);
      }
      index = index + 1;
    }

    setState(() {
      isLoading = false;
    });

    // Initialize default settings
    if (settingsBox.isEmpty) {
      settingsBox.add(VideoSettings());
    }

    setState(() {});
  }

  Future<File> computeFunc(FileObject obj) async {
    final ext = obj.type == 'video' ? 'mp4' : 'jpg';
    final fileName =
        '${DateTime.now().millisecondsSinceEpoch}_${obj.index}.$ext';
    final file = File('${obj.directory}/$fileName');

    // write bytes and then validate basic sanity (size > small threshold)
    await file.writeAsBytes(obj.response.bodyBytes);
    final size = await file.length();
    if (size < 1000) {
      // very small file likely corrupt
      throw Exception('Downloaded file too small ($size bytes)');
    }
    return file;
  }

  // Future<File> computeFunc(FileObject obj) {
  //   final fileName =
  //       '${DateTime.now().second}${obj.index}.${obj.type == 'video' ? 'mp4' : 'jpg'}';
  //   final file = File('${obj.directory}/$fileName');
  //   return file.writeAsBytes(obj.response.bodyBytes);
  // }

  Future<File> downloadImageFile(
    String url, {
    String type = 'video',
    int index = 0,
  }) async {
    final directory = await getApplicationDocumentsDirectory();

    // strip fragment and normalize URL
    final uri = Uri.parse(url).replace(fragment: '');
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to download file: ${response.statusCode} ${uri.toString()}',
      );
    }

    final fileObj = FileObject(
      response,
      type: type,
      index: index.toString(),
      directory: directory.path,
    );

    final file = await computeFunc(fileObj);

    // optional: quick mime check (requires package:mime) or at least log
    print('Saved file: ${file.path}, size=${await file.length()}');

    return file;
  }

  // Future<File> downloadImageFile(String url, {String type = 'video', int index = 0}) async {
  //   final directory = await getApplicationDocumentsDirectory();
  //   final response = await http.get(Uri.parse(url));

  //   var pass = FileObject(response, type: type, index: index.toString(), directory: directory.path);

  //   final file = await computeFunc(pass);

  //   return file;
  // }

  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode1 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  bool _isFocused = false;

  @override
  void dispose() {
    _focusNode2.dispose();
    _focusNode1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffdae3f3),
      body: Column(
        children: [
          if (isLoading) LinearProgressIndicator(),
          SingleChildScrollView(
            padding: const EdgeInsets.only(top: 20),
            child: Row(
              children: [
                SizedBox(width: 20),

                // Focus(
                //   focusNode: _focusNode1,
                //   onKey: (FocusNode node, RawKeyEvent event) {
                //     // Handle key presses here. This is an alternative to the default
                //     // traversal, useful for custom logic like navigating in a specific order
                //     // or handling 'OK' button presses.
                //     if (event is RawKeyDownEvent) {
                //       if (event.logicalKey == LogicalKeyboardKey.select) {
                //         // A common key for the 'OK' or 'Select' button on a TV remote.
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(builder: (context) => YoutubeVideo()),
                //           // MaterialPageRoute(builder: (context) => VideoPlayerScreenChiwe(videoItems: mediaBox.values.toList())),
                //         );
                //         return KeyEventResult.handled;
                //       }
                //     }
                //     return KeyEventResult.ignored;
                //   },
                //   child: GestureDetector(
                //     onTap: (){
                //       Navigator.push(
                //         context,
                //         MaterialPageRoute(builder: (context) => YoutubeVideo()),
                //         // MaterialPageRoute(builder: (context) => VideoPlayerScreenChiwe(videoItems: mediaBox.values.toList())),
                //       );
                //     },
                //     child: Container(
                //       height: _isFocused ? 250 : 200,
                //       width: _isFocused ? 250 : 200,
                //       decoration: BoxDecoration(
                //         color: Colors.white,
                //         borderRadius: BorderRadius.circular(20),
                //         image: DecorationImage(
                //           image: NetworkImage(
                //             'https://images.pexels.com/photos/235986/pexels-photo-235986.jpeg?_gl=1*8uc70f*_ga*MTQwOTg1NjM3MC4xNzU1MDE1MDQ2*_ga_8JE65Q40S6*czE3NTUwMTUwNDUkbzEkZzEkdDE3NTUwMTUwNTQkajUxJGwwJGgw',
                //           ),
                //         ),
                //       ),
                //       child: Column(
                //         mainAxisAlignment: MainAxisAlignment.center,
                //         crossAxisAlignment: CrossAxisAlignment.center,
                //         children: [Text("Images", style: TextStyle(color: Colors.white, fontSize: 30))],
                //       ),
                //     ),
                //   ),
                // ),
                // SizedBox(width: 40),
                Focus(
                  focusNode: _focusNode2,
                  onKey: (FocusNode node, RawKeyEvent event) {
                    // Handle key presses here. This is an alternative to the default
                    // traversal, useful for custom logic like navigating in a specific order
                    // or handling 'OK' button presses.
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.select) {
                        // A common key for the 'OK' or 'Select' button on a TV remote.
                        _navigateToMediaList('video');
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: GestureDetector(
                    onTap: () {
                      _navigateToMediaList('video');
                    },
                    child: Container(
                      height: _isfocusedVideop ? 250 : 200,
                      width: _isfocusedVideop ? 250 : 200,
                      padding: const EdgeInsets.symmetric(horizontal: 0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        border: Border(
                          top: BorderSide(color: Color(0xff264378), width: 1.5),
                          bottom: BorderSide(
                            color: Color(0xff264378),
                            width: 1.5,
                          ),
                          left: BorderSide(
                            color: Color(0xff264378),
                            width: 1.5,
                          ),
                          right: BorderSide(
                            color: Color(0xff264378),
                            width: 1.5,
                          ),
                        ),
                        boxShadow: [],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(40),
                            child: Image.asset(
                              "assets/images/plane_1.jpg",
                              fit: BoxFit.fill,
                              height: _isfocusedVideop ? 250 : 200,
                              width: _isfocusedVideop ? 250 : 200,
                            ),
                          ),

                          Positioned(
                            bottom: 6,
                            left: 20,
                            width: 300,

                            child: Text(
                              "Travel Insurance",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  // BoxShadow(color: Colors.transparent,offset: Offset(0, 0)),
                                  BoxShadow(
                                    color: Colors.grey,
                                    offset: Offset(0, 0),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 40),
                Focus(
                  focusNode: _focusNode3,
                  onKey: (FocusNode node, RawKeyEvent event) {
                    // Handle key presses here. This is an alternative to the default
                    // traversal, useful for custom logic like navigating in a specific order
                    // or handling 'OK' button presses.
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.select) {
                        // A common key for the 'OK' or 'Select' button on a TV remote.
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoggerPage()),
                          // MaterialPageRoute(
                          //   builder: (context) =>
                          //   VideoPlayerWidget(
                          //     videoUrl:
                          //         'https://rl-video.ralphlauren.com/v2/2025/06/20250603-home-lp/RL-Hamptons-Home-DSK.mp4',
                          //   ),
                          // ),
                          // MaterialPageRoute(builder: (context) => VideoPlayerScreenChiwe(videoItems: mediaBox.values.toList())),
                        );
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        // MaterialPageRoute(
                        //   builder: (context) => VideoPlayerWidget(
                        //     videoUrl:
                        //         'https://rl-video.ralphlauren.com/v2/2025/06/20250603-home-lp/RL-Hamptons-Home-DSK.mp4',
                        //   ),
                        // ),
                        MaterialPageRoute(builder: (context) => LoggerPage()),
                      );
                    },
                    child: Container(
                      height: _isLoggerOpen ? 250 : 200,
                      width: _isLoggerOpen ? 250 : 200,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "LOGGER",
                            style: TextStyle(color: Colors.black, fontSize: 30),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                SizedBox(width: 40),
                Focus(
                  focusNode: _focusNode4,
                  onKey: (FocusNode node, RawKeyEvent event) {
                    // Handle key presses here. This is an alternative to the default
                    // traversal, useful for custom logic like navigating in a specific order
                    // or handling 'OK' button presses.
                    if (event is RawKeyDownEvent) {
                      if (event.logicalKey == LogicalKeyboardKey.select) {
                        // A common key for the 'OK' or 'Select' button on a TV remote.
                        Navigator.push(
                          context,

                          MaterialPageRoute(
                            builder: (context) => VideoNetwork(
                              source:
                                  'https://media.w3.org/2010/05/sintel/trailer.mp4',
                            ),
                          ),
                          // MaterialPageRoute(builder: (context) => VideoPlayerScreenChiwe(videoItems: mediaBox.values.toList())),
                        );
                        return KeyEventResult.handled;
                      }
                    }
                    return KeyEventResult.ignored;
                  },
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => VideoNetwork(
                            source:
                                'https://media.w3.org/2010/05/sintel/trailer.mp4',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      height: _isNetworkVideoPlay ? 250 : 200,
                      width: _isNetworkVideoPlay ? 250 : 200,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "VIDEO NETWORK",
                            style: TextStyle(color: Colors.black, fontSize: 30),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                //
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToMediaList(String type) {
    Navigator.push(
      context,
      // MaterialPageRoute(builder: (context) => YoutubeVideo()),
      MaterialPageRoute(
        builder: (context) =>
            VideoPlayerScreenChiwe(videoItems: mediaBox.values.toList()),
      ),
    );
  }
}

class FileObject {
  final String type;
  final String index;
  final String directory;
  final http.Response response;

  FileObject(
    this.response, {
    required this.type,
    required this.index,
    required this.directory,
  });

  @override
  String toString() {
    return 'FileObject(type: $type, index: $index)';
  }
}
