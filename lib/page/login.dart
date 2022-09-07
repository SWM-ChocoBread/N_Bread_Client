import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
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

  Widget _kakaologinSDK() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xffFEE500),
          side: const BorderSide(width: 1.0, color: Color(0xffFEE500)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20)),
      onPressed: () async {
        // 기존에 발급받아 저장된 토큰이 있는 경우 (로그아웃한 경우, 바로 로그인되어 홈 화면으로 이동하도록 처리)
        if (await AuthApi.instance.hasToken()) {
          try {
            // 토큰의 유효성을 체크한다.
            AccessTokenInfo tokenInfo =
                await UserApi.instance.accessTokenInfo();
            print('토큰 유효성 체크 성공 ${tokenInfo.id} ${tokenInfo.expiresIn}');
            // (자동 로그인) 유효한 토큰이 이미 있는 경우, 홈 화면으로 navigator
            // 이전에 로그인한 기록이 있다면, 홈 화면으로 이동 (이전 stack 비우기)
            SharedPreferences prefs = await SharedPreferences.getInstance();
            bool isTerms = prefs.getBool("isTerms") ?? false; // 약관에 모두 동의했는지 여부
            bool isNickname =
                prefs.getBool("isNickname") ?? false; // 닉네임을 설정했는지 여부
            if (isTerms && isNickname) {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const App()),
                  (route) => false);
            }
          } catch (error) {
            // 토큰이 유효성 체크 중 에러 발생 == 토큰이 있으나 (만료된 경우 || 토큰 정보 조회에 실패한 경우)
            if (error is KakaoException && error.isInvalidTokenError()) {
              print('토큰 만료 $error');
            } else {
              print('토큰 정보 조회 실패 $error');
            }

            try {
              // 카카오 계정으로 로그인
              OAuthToken token = await UserApi.instance.loginWithKakaoAccount();
              print('로그인 성공 ${token.accessToken}');
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const App()),
                  (route) => false);
            } catch (error) {
              print('로그인 실패 $error');
            }
          }
        } else {
          // 기존에 발급받아 저장된 토큰이 없는 경우 (처음 회원가입하는 경우)
          print('발급된 토큰 없음');
          // 카카오톡 설치 여부 확인
          // 카카오톡이 설치되어 있으면 카카오톡으로 로그인, 아니면 카카오계정으로 로그인
          if (await isKakaoTalkInstalled()) {
            // 카카오톡이 설치된 경우, 카카오톡으로 로그인하기
            try {
              // await UserApi.instance.loginWithKakaoTalk();
              OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
              print('카카오톡으로 로그인 성공 : ${token.accessToken}');
              // 이전에 로그인한 기록이 없다면, 회원가입 프로세스인 약관 동의로 이동 (이전 stack 비우기)
              Navigator.pushNamedAndRemoveUntil(
                  context, '/termscheck', (route) => false);
            } catch (error) {
              print('카카오톡으로 로그인 실패 $error');

              // 사용자가 카카오톡 설치 후 디바이스 권한 요청 화면에서 로그인을 취소한 경우,
              // 의도적인 로그인 취소로 보고 카카오계정으로 로그인 시도 없이 로그인 취소로 처리 (예: 뒤로 가기)
              if (error is PlatformException && error.code == 'CANCELED') {
                return;
              }
              // 카카오톡에 연결된 카카오계정이 없는 경우, 카카오계정으로 로그인
              try {
                // await UserApi.instance.loginWithKakaoAccount();
                OAuthToken token =
                    await UserApi.instance.loginWithKakaoAccount();
                print('카카오계정으로 로그인 성공 : ${token.accessToken}');
                // 이전에 로그인한 기록이 없다면, 회원가입 프로세스인 약관 동의로 이동 (이전 stack 비우기)
                Navigator.pushNamedAndRemoveUntil(
                    context, '/termscheck', (route) => false);
              } catch (error) {
                print('카카오계정으로 로그인 실패 $error');
              }
            }
          } else {
            // 카카오톡이 설치되어 있지 않은 경우, 카카오계정으로 로그인하기
            try {
              await UserApi.instance.loginWithKakaoAccount();
              print('카카오계정으로 로그인 성공');
              // 이전에 로그인한 기록이 없다면, 회원가입 프로세스인 약관 동의로 이동 (이전 stack 비우기)
              Navigator.pushNamedAndRemoveUntil(
                  context, '/termscheck', (route) => false);
            } catch (error) {
              print('카카오계정으로 로그인 실패 $error');
            }
          }
        }
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

  Widget _kakaologoutSDK() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: const Color(0xffFEE500),
          side: const BorderSide(width: 1.0, color: Color(0xffFEE500)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20)),
      onPressed: () async {
        try {
          await UserApi.instance.logout();
          print('로그아웃 성공, SDK에서 토큰 삭제');
        } catch (error) {
          print('로그아웃 실패, SDK에서 토큰 삭제 $error');
        }
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
                "카카오 로그아웃 SDK",
                style:
                    TextStyle(color: const Color(0xff000000).withOpacity(0.85)),
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
              _kakaologinSDK(),
              const SizedBox(
                height: 10,
              ),
              _kakaologoutSDK(),
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
