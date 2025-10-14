
class Channel{
  String title;
  String description;
  String thumb;
  List<String> sources;
  Channel({required this.title,required this.description,required this.thumb,required this.sources});

  factory Channel.fromJson(Map<dynamic,dynamic> json){

    return Channel(
      title:json['title'],
      description:json['description'],
      thumb:json['thumb'],
      sources:json['sources'],
    );
  }
}

class ChannelsList{

  List<Channel> channels;
  ChannelsList(this.channels);

  factory ChannelsList.fromJson(Map<dynamic,dynamic> json){
    var list=List<Channel>.empty(growable: true);
    if (json['videos'] != null) {
      json['videos'].forEach((v) {
        final model = Channel.fromJson(v);
        list.add(model);
      });
    }
    return ChannelsList(list);
  }
}