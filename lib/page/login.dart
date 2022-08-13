import 'package:chocobread/style/colorstyles.dart';
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
    return AppBar(
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false, // 자동으로 생성되는 뒤로가기 버튼 제거하기
    );
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
        children: [
          SvgPicture.asset(
            "assets/logo/naver.svg",
            color: Colors.white,
          ),
          const Expanded(
            child: Center(
              child: Text(
                "네이버 로그인",
                style: TextStyle(color: Colors.white),
              ),
            ),
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
          Expanded(
            child: Center(
              child: Text(
                "카카오 로그인",
                style:
                    TextStyle(color: const Color(0xff000000).withOpacity(0.85)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _applelogin() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(width: 1.0, color: Colors.white),
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
            "assets/svg/apple_logo.svg",
            width: 17,
            // color: Colors.black,
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Apple로 로그인",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bodyWidget() {
    return Container(
      color: ColorStyle.mainColor,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/logo/mylogo.jpeg",
                width: 200,
              ),
              const SizedBox(
                height: 50,
              ),
              const Text(
                "간편하게 SNS 회원 가입",
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(
                height: 10,
              ),
              Container(
                color: Colors.white,
                height: 0.5,
              ),
              const SizedBox(
                height: 15,
              ),
              // _naverlogin(),
              // const SizedBox(
              //   height: 10,
              // ),
              _kakaologin(),
              const SizedBox(
                height: 10,
              ),
              _applelogin(),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 앱 바 위에까지 침범 허용
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
