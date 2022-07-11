import 'package:chocobread/page/app.dart';
import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);
  static String routeName = "/splash";

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushReplacementNamed(context, App.routeName);
    });

    return Container(
        child: const Center(
      child: Text("N 빵"),
    ));
  }
}
