// Model for your downloaded file
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class DownloadedFile extends HiveObject {
  @HiveField(0)
  late String url;

  @HiveField(1)
  late String localPath;

  @HiveField(2)
  late String fileType; // 'image' or 'video'

  DownloadedFile({
    required this.url,
    required this.localPath,
    required this.fileType,
  });
}