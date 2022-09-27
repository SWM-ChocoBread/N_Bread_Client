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
      child: Center(
        child: Text("Page 3"),
      ),
    );
  }
}
