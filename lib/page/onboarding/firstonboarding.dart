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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              "동네 이웃과 함께 구매해요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/onboardings/firstonboarding.png",
              width: 320,
            ),
            const SizedBox(
              height: 50,
            ),
            const Text(
              "혼자서는 선뜻 구매하지 못했던 물건들을",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "N빵에서 구매해요!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 30,
            ),
          ]),
        ),
      ),
    );
  }
}