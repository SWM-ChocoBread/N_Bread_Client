import 'package:chocobread/page/onboarding/firstonboarding.dart';
import 'package:chocobread/page/onboarding/fourthonboarding.dart';
import 'package:chocobread/page/onboarding/secondonboarding.dart';
import 'package:chocobread/page/onboarding/thirdonboarding.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../app.dart';

class Onboarding extends StatefulWidget {
  Onboarding({Key? key}) : super(key: key);

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  // page counter : 페이지 개수
  int pageCounter = 4;
  int myDuration = 100;

  // controller to keep track of which page we're on
  PageController _controller = PageController();

  // keep track of if we are on the last page or not
  bool onLastPage = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        PageView(
          controller: _controller,
          onPageChanged: (index) {
            _controller.animateToPage(index,
                duration: Duration(milliseconds: myDuration),
                curve: Curves.easeIn);
            if (index == (pageCounter - 1)) {
              setState(() {
                onLastPage = true;
              });
            } else {
              setState(() {
                onLastPage = false;
              });
            }
          },
          children: [
            FirstOnboarding(),
            SecondOnboarding(),
            ThirdOnboarding(),
            FourthOnboarding(),
          ],
        ),

        // dot indicators
        Align(
            alignment: const Alignment(0, 0.65),
            child: SmoothPageIndicator(
              controller: _controller,
              count: pageCounter,
              effect: WormEffect(
                  dotColor: Colors.grey.withOpacity(0.5),
                  activeDotColor: ColorStyle.mainColor),
              onDotClicked: (index) {
                _controller.animateToPage(index,
                    duration: Duration(milliseconds: myDuration),
                    curve: Curves.easeIn);
                if (index == (pageCounter - 1)) {
                  setState(() {
                    onLastPage = true;
                  });
                } else {
                  setState(() {
                    onLastPage = false;
                  });
                }
              },
            )),

        // 다음 버튼 or 시작하기 버튼
        onLastPage
            ? Align(
                alignment: const Alignment(0, 0.85),
                child: Container(
                  margin: const EdgeInsets.all(15),
                  width: double.infinity,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: ColorStyle.mainColor,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 20)),
                      onPressed: () {
                        // 홈 화면으로 이동
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (BuildContext context) => const App()),
                            (route) => false);
                      },
                      child: const Text(
                        "시작하기",
                        style: TextStyle(color: Colors.white),
                      )),
                ))
            : Align(
                alignment: const Alignment(0, 0.85),
                child: Container(
                  margin: const EdgeInsets.all(15),
                  width: double.infinity,
                  child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          backgroundColor: ColorStyle.mainColor,
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 13, horizontal: 20)),
                      onPressed: () {
                        _controller.nextPage(
                            duration: Duration(milliseconds: myDuration),
                            curve: Curves.easeIn);
                      },
                      child: const Text(
                        "다음",
                        style: TextStyle(color: Colors.white),
                      )),
                )),
      ]),
    );
  }
}
