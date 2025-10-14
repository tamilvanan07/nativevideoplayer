// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_type.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoSettingsAdapter extends TypeAdapter<VideoSettings> {
  @override
  final int typeId = 1;

  @override
  VideoSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VideoSettings(
      playDuration: fields[0] as int,
      autoPlay: fields[1] as bool,
      volume: fields[2] as double,
      filePath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, VideoSettings obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.playDuration)
      ..writeByte(1)
      ..write(obj.autoPlay)
      ..writeByte(2)
      ..write(obj.volume)
      ..writeByte(3)
      ..write(obj.filePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
