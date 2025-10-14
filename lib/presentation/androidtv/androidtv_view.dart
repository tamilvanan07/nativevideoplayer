
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'list_page.dart';

class AndroidtvView extends StatefulWidget {
  const AndroidtvView({super.key});

  @override
  State<AndroidtvView> createState() => _AndroidtvViewState();
}

class _AndroidtvViewState extends State<AndroidtvView> {

  void initCall() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ListScreen()));
    });
  }


  @override
  void initState() {
    initCall();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            Expanded(
                child: ColoredBox(
                    color: Color(0xffdae3f3),
                  child: Center(
                    child: SvgPicture.asset("assets/images/launchIcon.svg",),
                  )
                )),
            Expanded(
                child: ColoredBox(
                    color: Color(0xff264378),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Device Activation Code", style: TextStyle(fontSize: 27, color: Colors.white),),
                      SizedBox(height: 30,),
                      Text(
                        "A1B2C3",
                        style: TextStyle(
                           color: Colors.white,),textScaler: TextScaler.linear(5),
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
