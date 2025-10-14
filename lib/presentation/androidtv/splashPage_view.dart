import 'package:androidtv/presentation/androidtv/androidtv_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SplashPageView extends StatefulWidget {
  const SplashPageView({super.key});

  @override
  State<SplashPageView> createState() => _SplashPageViewState();
}

class _SplashPageViewState extends State<SplashPageView> {
  void initCall() {
    Future.delayed(Duration(seconds: 2), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AndroidtvView()));
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
      backgroundColor: Color(0xffdae3f3),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.sizeOf(context).width,
          width: MediaQuery.sizeOf(context).width,
          child: Center(child: SvgPicture.asset("assets/images/launchIcon.svg")),
        ),
      ),
    );
  }
}
