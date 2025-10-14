// Hive Models
import 'package:hive/hive.dart';

part 'media_time.g.dart';

@HiveType(typeId: 0)
class MediaItem extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String url;

  @HiveField(3)
  late String localPath;

  @HiveField(4)
  late String type; // 'video' or 'image'

  @HiveField(5)
  late bool isDownloaded;

  @HiveField(6)
  late DateTime createdAt;

  @HiveField(7)
  String? filePath ;

  @HiveField(8)
  String? timer ;

  MediaItem({
    required this.id,
    required this.title,
    required this.url,
    required this.localPath,
    required this.type,
    this.isDownloaded = false,
    this.filePath,
    this.timer,
    required this.createdAt,
  });
}

