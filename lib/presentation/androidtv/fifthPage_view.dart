import 'package:flutter/material.dart';

class FifthPageView extends StatelessWidget {
  const FifthPageView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SizedBox(
            height: MediaQuery.sizeOf(context).width,
            width: MediaQuery.sizeOf(context).width,
            child: Image.asset("assets/images/plane_4.jpg", fit: BoxFit.cover,)),
      ),
    );
  }
}
