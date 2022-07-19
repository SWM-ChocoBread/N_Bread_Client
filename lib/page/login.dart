import 'package:flutter/material.dart';

class KakaoLogin extends StatefulWidget {
  KakaoLogin({Key? key}) : super(key: key);

  @override
  State<KakaoLogin> createState() => _KakaoLoginState();
}

class _KakaoLoginState extends State<KakaoLogin> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar();
  }

  Widget _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.all(15),
      child: Center(
        child: Column(
          children: [
            OutlinedButton(
              onPressed: () {},
              child: const Text("Naver 로 로그인하기"),
            ),
            OutlinedButton(
              onPressed: () {},
              child: const Text("Kakao 로 로그인하기"),
            ),
            const SizedBox(
              height: 10,
            ),
            const Text("여기에 리턴되는 string을 넣어주세요!")
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
