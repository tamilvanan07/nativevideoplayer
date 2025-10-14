
import 'package:androidtv/tv_player.dart';
import 'package:flutter/material.dart';

import 'main.dart';
import 'model.dart';
import 'modelJson.dart';

class ChannelList extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Channel List"),),
      body: Material(
        child: FutureBuilder(
          future: laodChannels(),
          builder: (BuildContext context, AsyncSnapshot<List<Channel>> snapshot) {
            if(snapshot!.hasData)
            {
              var list=snapshot.data;
              return ListView.builder(
                  itemCount: (list==null)?0:snapshot.data!.length,
                  itemBuilder: (item,index){
                    return MaterialButton(onPressed:(){
                      Navigator.push(context, MaterialPageRoute(builder: (context){
                        return MyTvScreen(url:snapshot.data![index].sources[0]);
                      }));
                    },child: Card(child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(leading:Image.network("http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/${snapshot.data![index].thumb}",height:100),title:Text(snapshot.data![index].title ),),
                    )));
                  });
            }
            return Container();
          },

        ),
      ),
    );
  }
  Future<List<Channel>> laodChannels(){
    return Future.value(ChannelsList.fromJson(mediaJSON).channels);
  }

}