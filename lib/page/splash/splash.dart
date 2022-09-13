import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/app.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // static String routeName = "/splash";

  void checkStatus() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // getInstance로 기기 내 shared_prefs 객체를 가져온다.

    //prefs.clear();
    // TODO : 닉네임 설정 완료 여부를 확인하는 API를 호출하는 부분
    bool hasToken = false;
    String? userToken = prefs.getString("userToken");

    if (userToken != null) {
      hasToken = true;
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);

      String userId = payload['id'].toString();

      String tmpUrl = 'https://www.chocobread.shop/users/check/' + userId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print("splash에서의 list : ${list}");
      if (list['code'] == 200) {
        print("코드가 200입니다. 홈화면으로 리다이렉트합니다.");
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const App()),
            (route) => false);
      } else if (list['code'] == 300 || list['code'] == 404) {
        print("코드가 ${list['code']}입니다. 약관동의 화면으로 리다이렉트합니다.");
        Navigator.pushNamedAndRemoveUntil(
              context, '/termscheck', (route) => false);
      } else {
        print("서버 에러가 발생하였습니다. 로그인 화면으로 리다이렉트합니다.");
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } else {
      //토큰이 로컬 스토리지에 없으면 로그인 화면으로 이동.
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
    print("[*] 유저 토큰 : " + userToken.toString());
  }

  // void moveScreen() async {
  //   await checkStatus().then((hasToken) {
  //     if (hasToken) {
  //       // 이전에 로그인한 기록이 있다면, 홈 화면으로 이동 (이전 stack 비우기)
  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (BuildContext context) => const App()),
  //           (route) => false);
  //     } else {
  //       // 이전에 로그인한 기록이 없다면, 로그인 화면으로 이동 (이전 stack 비우기)
  //       Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  //     }
  //   });
  // }

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
      checkStatus();
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
