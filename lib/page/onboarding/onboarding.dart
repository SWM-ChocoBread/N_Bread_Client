import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';

class Onboarding extends StatefulWidget {
  Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          Container(
            color: ColorStyle.mainColor,
          ),
          Container(
            color: ColorStyle.lightMainColor,
          ),
          Container(
            color: ColorStyle.darkMainColor,
          )
        ],
      ),
    );
  }
}
