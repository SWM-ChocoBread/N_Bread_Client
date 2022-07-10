import 'package:flutter/material.dart';

class Splash extends StatelessWidget {
  const Splash({Key? key}) : super(key: key);
  static String routeName = "/screens";

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Center(
      child: Text("N 빵"),
    ));
  }
}
