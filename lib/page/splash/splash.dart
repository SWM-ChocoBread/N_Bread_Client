import 'dart:async';

import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/app.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // static String routeName = "/splash";

  Future<bool> checkStatus() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // getInstance로 기기 내 shared_prefs 객체를 가져온다.

    //prefs.clear();
    // TODO : 닉네임 설정 완료 여부를 확인하는 API를 호출하는 부분
    bool isNickname = prefs.getBool("isNickname") ?? false; // 닉네임을 설정했는지 여부
    String? userToken = prefs.getString("userToken");

    print("[*] 닉네임 설정 상태 : " + isNickname.toString());
    print("[*] 유저 토큰 : " + userToken.toString());
    return isNickname;
  }

  void moveScreen() async {
    await checkStatus().then((wasUser) {
      if (wasUser) {
        // 이전에 로그인한 기록이 있다면, 홈 화면으로 이동 (이전 stack 비우기)
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const App()),
            (route) => false);
      } else {
        // 이전에 로그인한 기록이 없다면, 로그인 화면으로 이동 (이전 stack 비우기)
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    });
  }

  // sharedPreferences 초기화 위해 사용하는 함수
  void clearSharedPreferences() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      // clearSharedPreferences(); // sharedPreferences 초기화 위해 사용하는 함수
      moveScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: ColorStyle.mainColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo/mylogo.jpeg",
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ],
        ));
  }
}
