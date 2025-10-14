import 'package:androidtv/presentation/androidtv/fifthPage_view.dart';
import 'package:flutter/material.dart';

class FourthPageView extends StatelessWidget {
  const FourthPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: (){
            Navigator.push(context, MaterialPageRoute(builder: (_)=> FifthPageView()));
          },
          child: SizedBox(
              height: MediaQuery.sizeOf(context).width,
              width: MediaQuery.sizeOf(context).width,
              child: Image.asset("assets/images/plane_3.jpg", fit: BoxFit.cover,)),
        ),
      ),
    );
  }
}
