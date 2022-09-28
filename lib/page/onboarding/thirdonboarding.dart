import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';

class ThirdOnboarding extends StatefulWidget {
  ThirdOnboarding({Key? key}) : super(key: key);

  @override
  State<ThirdOnboarding> createState() => _ThirdOnboardingState();
}

class _ThirdOnboardingState extends State<ThirdOnboarding> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              "이웃과 함께 구매에 참여해요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 27,
            ),
            Image.asset(
              "assets/onboardings/thirdonboarding.png",
              width: double.infinity,
            ),
            const SizedBox(
              height: 27,
            ),
            const Text(
              "원하는 물품을 구매하기 위해",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "거래에 참여해보세요",
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
