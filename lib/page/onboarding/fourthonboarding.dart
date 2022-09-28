import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';

class FourthOnboarding extends StatefulWidget {
  FourthOnboarding({Key? key}) : super(key: key);

  @override
  State<FourthOnboarding> createState() => _FourthOnboardingState();
}

class _FourthOnboardingState extends State<FourthOnboarding> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              "동네 이웃과 함께 산 물품을 나눠요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 20,
            ),
            Image.asset(
              "assets/onboardings/fourthonboarding.png",
              width: 300,
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "약속 시간에 약속 장소에서 만나",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "함께 구매한 물품을 나눠요",
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
