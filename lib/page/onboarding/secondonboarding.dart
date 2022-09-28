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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Text(
              "이웃과 함께 구매할 물품을",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "제안해보세요",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 75,
            ),
            Image.asset(
              "assets/onboardings/secondonboarding.png",
              width: double.infinity,
            ),
            const SizedBox(
              height: 75,
            ),
            const Text(
              "상품 정보와 거래 시간, 장소를 입력하여",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 5,
            ),
            const Text(
              "같이 구매할 참여자들을 모아보세요",
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
