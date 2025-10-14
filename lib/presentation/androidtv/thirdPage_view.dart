import 'package:androidtv/presentation/androidtv/fourthPage_view.dart';
import 'package:flutter/material.dart';

class ThirdPageView extends StatelessWidget {
  const ThirdPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> FourthPageView()));
          },
          child: SizedBox(
              height: MediaQuery.sizeOf(context).width,
              width: MediaQuery.sizeOf(context).width,
              child: Image.asset("assets/images/plane_2.jpg", fit: BoxFit.cover,)),
        ),
      ),
    );
  }
}
