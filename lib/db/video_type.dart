import 'package:hive/hive.dart';

part 'video_type.g.dart';

@HiveType(typeId: 1)
class VideoSettings extends HiveObject {
  @HiveField(0)
  late int playDuration; // seconds per video

  @HiveField(1)
  late bool autoPlay;

  @HiveField(2)
  late double volume;

  @HiveField(3)
  String? filePath ;

  VideoSettings({
    this.playDuration = 10,
    this.autoPlay = true,
    this.volume = 1.0,
    this.filePath
  });
}

