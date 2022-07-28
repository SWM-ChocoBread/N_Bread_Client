import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import 'appleloginwebview.dart';
import 'kakaologinwebview.dart';
import 'naverloginwebview.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar();
  }

  Widget _naverlogin() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xff03c75a),
          side: const BorderSide(width: 1.0, color: Color(0xff03c75a)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20)),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return NaverLoginWebview();
        }));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/logo/naver.svg",
            color: Colors.white,
          ),
          const SizedBox(
            width: 13,
          ),
          const Text(
            "네이버 로그인",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _kakaologin() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xffFEE500),
          side: const BorderSide(width: 1.0, color: Color(0xffFEE500)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20)),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return KakaoLoginWebview();
        }));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            "assets/logo/kakao.png",
            color: const Color(0xff000000),
            width: 18,
          ),
          const SizedBox(
            width: 13,
          ),
          Text(
            "카카오 로그인",
            style: TextStyle(color: const Color(0xff000000).withOpacity(0.85)),
          ),
        ],
      ),
    );
  }

  Widget _applelogin() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: Colors.black,
          side: const BorderSide(width: 1.0, color: Colors.black),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20)),
      onPressed: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (BuildContext context) {
          return AppleLoginWebview();
        }));
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            "assets/logo/apple.svg",
            width: 20,
          ),
          const SizedBox(
            width: 10,
          ),
          const Text(
            "Apple로 로그인",
            style: TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            Container(
              height: 200,
            ),
            _naverlogin(),
            const SizedBox(
              height: 10,
            ),
            _kakaologin(),
            const SizedBox(
              height: 10,
            ),
            _applelogin(),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
