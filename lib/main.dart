import 'package:androidtv/presentation/androidtv/list_page.dart';
import 'package:androidtv/presentation/androidtv/splashPage_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'channel_list.dart';
import 'db/media_time.dart';
import 'db/video_type.dart';
import 'logger/logger_file.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  // WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register adapters
  Hive.registerAdapter(MediaItemAdapter());
  Hive.registerAdapter(VideoSettingsAdapter());
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger().logException('FlutterError', details.exception, details.stack);
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Tv',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ListScreen(),
    );
  }
}


class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
        home: ChannelList( ),
      ),
    );
  }
}
