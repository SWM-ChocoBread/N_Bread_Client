import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';

class FirstOnboarding extends StatefulWidget {
  FirstOnboarding({Key? key}) : super(key: key);

  @override
  State<FirstOnboarding> createState() => _FirstOnboardingState();
}

class _FirstOnboardingState extends State<FirstOnboarding> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(
            "동네 이웃과 함께 구매해요!",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          Text("혼자서는 선뜻 구매하지 못했던 물건들을 N빵에서 구매해요!")
        ]),
      ),
    );
  }
}
