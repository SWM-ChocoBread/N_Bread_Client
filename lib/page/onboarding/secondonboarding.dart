import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';

class SecondOnboarding extends StatefulWidget {
  SecondOnboarding({Key? key}) : super(key: key);

  @override
  State<SecondOnboarding> createState() => _SecondOnboardingState();
}

class _SecondOnboardingState extends State<SecondOnboarding> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text("Page 2"),
      ),
    );
  }
}
