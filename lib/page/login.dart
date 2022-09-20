import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:chocobread/page/mypage.dart';
import 'package:chocobread/page/termscheck.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart' as Airbridge;
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:http/http.dart' as http;
import 'dart:io' show Platform;
import 'app.dart';
import 'appleloginwebview.dart';
import 'kakaologinwebview.dart';
import 'naverloginwebview.dart';

//혜연
//아래 코드는 300일 경우 약관 동의 화면으로, 200일 경우 홈 화면으로 리다이렉트 시켜줘야합니다.
int code = 0;
String userId = "";
String userEmail = "";
String kakaoSeverEmail = "";

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
        print("눌림");

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
            // TODO : (추가해야 할 사항) 닉네임 설정 여부를 확인하는 API 호출 추가하기

            try {
              User user = await UserApi.instance.me();
              print('사용자 정보 요청 성공, 이 유저는 이전에 카카오 SDK로 로그인 한 사람입니다.'
                  '\n회원번호: ${user.id}'
                  '\n이메일: ${user.kakaoAccount?.email}');
              print("kakaoSdkLogin함수가 호출되었습니다.");
              await kakaoSdkLogin(user.id.toString(), user.kakaoAccount?.email);
              print("code 가 ${code}로 설정되었습니다.");
            } catch (error) {
              print('토큰 유효성 체크 성공에서 사용자 정보 요청에 실패하였습니다. $error');
            }

            // SharedPreferences prefs = await SharedPreferences.getInstance();
            // bool isNickname =
            //     prefs.getBool("isNickname") ?? false; // 닉네임을 설정했는지 여부
            // if (isNickname) {
            //   // 카카오 SDK로 로그인을 하고 난 후, 이전에 약관 동의와 닉네임 설정을 했었다면,
            //   // TODO : (수정해야 할 사항) 카카오 SDK로 로그인을 하고 난 후, 이전에 닉네임 설정까지 완료했다면(회원가입 과정을 모두 다 거쳤다면) 홈으로 이동
            //   Navigator.pushAndRemoveUntil(
            //       context,
            //       MaterialPageRoute(
            //           builder: (BuildContext context) => const App()),
            //       (route) => false);
            // } else {
            //   // 카카오 SDK로 로그인을 하고 난 후, 약관 동의와 닉네임 설정 과정을 완료하지 않고 앱을 나간 경우
            //   Navigator.pushAndRemoveUntil(
            //       context,
            //       MaterialPageRoute(
            //           builder: (BuildContext context) => TermsCheck()),
            //       (route) => false);
            // }
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
              try {
                User user = await UserApi.instance.me();
                print('사용자 정보 요청 성공, 이 유저는 이전에 로그인 하였으나, 토큰이 만료되어 재로그인한 사람입니다.'
                    '\n회원번호: ${user.id}'
                    '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
                    '\n이메일: ${user.kakaoAccount?.email}');
                print("kakaoSdkLogin함수가 호출되었습니다.");
                await kakaoSdkLogin(
                    user.id.toString(), user.kakaoAccount?.email);
                print("code 가 ${code}로 설정되었습니다.");
              } catch (error) {
                print('사용자 정보 요청 실패 $error');
              }
              // TODO : (추가해야 할 사항) 닉네임 설정 여부를 확인하는 API 호출 추가하기
              // SharedPreferences prefs = await SharedPreferences.getInstance();
              // bool isNickname =
              //     prefs.getBool("isNickname") ?? false; // 닉네임을 설정했는지 여부
              // if (isNickname) {
              //   // 카카오 계정으로 로그인에 성공하고, 이전에 회원가입 절차를 수행했던 사람이라면(닉네임 설정까지 완료했다면) 홈 화면으로 이동하기
              //   Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //           builder: (BuildContext context) => const App()),
              //       (route) => false);
              // } else {
              //   // 카카오 SDK로 로그인을 하고 난 후, 약관 동의와 닉네임 설정 과정을 완료하지 않고 앱을 나간 경우
              //   Navigator.pushAndRemoveUntil(
              //       context,
              //       MaterialPageRoute(
              //           builder: (BuildContext context) => TermsCheck()),
              //       (route) => false);
              // }
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
              try {
                User user = await UserApi.instance.me();
                kakaoSeverEmail = (user.kakaoAccount?.email).toString();
                print('사용자 정보 요청 성공/ 이 유저는 새로 sdk를 이용해 로그인하는 사람입니다.'
                    '\n회원번호: ${user.id}'
                    '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
                    '\n이메일: ${user.kakaoAccount?.email}');
                print("kakaoSdkLogin함수가 호출되었습니다.");
                await kakaoSdkLogin(
                    user.id.toString(), user.kakaoAccount?.email);
                print("code 가 ${code}로 설정되었습니다.");
              } catch (error) {
                print('사용자 정보 요청 실패 $error');
              }
              // Navigator.pushNamedAndRemoveUntil(
              //     context, '/termscheck', (route) => false);
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
                try {
                  User user = await UserApi.instance.me();
                  print('사용자 정보 요청 성공/ 이 유저는 새로 sdk를 이용해 로그인하는 사람입니다.'
                      '\n회원번호: ${user.id}'
                      '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
                      '\n이메일: ${user.kakaoAccount?.email}');
                  print("kakaoSdkLogin함수가 호출되었습니다.");
                  await kakaoSdkLogin(
                      user.id.toString(), user.kakaoAccount?.email);
                  print("code가 ${code}로 설정되었습니다.");
                } catch (error) {
                  print('사용자 정보 요청 실패 $error');
                }
                // 이전에 로그인한 기록이 없다면, 회원가입 프로세스인 약관 동의로 이동 (이전 stack 비우기)
                // Navigator.pushNamedAndRemoveUntil(
                //     context, '/termscheck', (route) => false);
              } catch (error) {
                print('카카오계정으로 로그인 실패 $error');
              }
            }
          } else {
            // 카카오톡이 설치되어 있지 않은 경우, 카카오계정으로 로그인하기
            try {
              await UserApi.instance.loginWithKakaoAccount();
              print('카카오계정으로 로그인 성공');
              try {
                User user = await UserApi.instance.me();
                print('사용자 정보 요청 성공/ 이 유저는 새로 sdk를 이용해 로그인하는 사람입니다.'
                    '\n회원번호: ${user.id}'
                    '\n닉네임: ${user.kakaoAccount?.profile?.nickname}'
                    '\n이메일: ${user.kakaoAccount?.email}');
                print("kakaoSdkLogin함수가 호출되었습니다.");
                await kakaoSdkLogin(
                    user.id.toString(), user.kakaoAccount?.email);
                print("code가 ${code}로 설정되었습니다.");
              } catch (error) {
                print('사용자 정보 요청 실패 $error');
              }
              // 이전에 로그인한 기록이 없다면, 회원가입 프로세스인 약관 동의로 이동 (이전 stack 비우기)
              // Navigator.pushNamedAndRemoveUntil(
              //     context, '/termscheck', (route) => false);
            } catch (error) {
              print('카카오계정으로 로그인 실패 $error');
            }
          }
        }
        if (code == 200) {
          print("code가 200입니다. 홈 화면으로 리다이렉트합니다.");
          final prefs = await SharedPreferences.getInstance();
          String? curLocation = prefs.getString("userLocation");
          if (curLocation == null) {
            print('curLocation이 null입니다. db에서 위치를 가져옵니다');
            String? token = prefs.getString("userToken");
            if (token != null) {
              Map<String, dynamic> payload = Jwt.parseJwt(token);
              int userId = payload['id'];
              String tmpUrl =
                  'https://www.chocobread.shop/users/' + userId.toString();
              var url = Uri.parse(
                tmpUrl,
              );
              var response = await http.get(url);
              String responseBody = utf8.decode(response.bodyBytes);
              Map<String, dynamic> list = jsonDecode(responseBody);
              String userProvider = list['result']['provider'];
              if (list['result']['addr'] == null) {
                prefs.setString("userLocation", "위치를 알 수 없는 사용자입니다");
                print(
                    "curLocation을 db에서 가져오려했으나 null입니다. 현재 로컬 스토리지에 저장된 curLocation은 ${prefs.getString('userLocation')}입니다");
              } else {
                prefs.setString("userLocation", list['result']['addr']);
                print(
                    "curLocation을 db에서 가져왔습니다. 현재 로컬 스토리지에 저장된 curLocation은 ${prefs.getString('userLocation')}입니다");
              }
              print("200 로그인 이벤트 전송 완료");
            } else {
              print("token is null");
            }
            //https://www.chocobread.shop/users/1
          }
          Airbridge.Airbridge.event.send(Airbridge.SignInEvent(
              user: Airbridge.User(
                  id: userId.toString(),
                  email: kakaoSeverEmail,
                  attributes: {
                "provider": "kakao",
                "curLocation": prefs.getString('userLocation')
              })));
          await FirebaseAnalytics.instance.logLogin(loginMethod: "kakao");
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (BuildContext context) => const App()),
              (route) => false);
        } else if (code == 300 || code == 301) {
          print("CODE : ${code}");
          if (code == 300) {
            print("code가 300입니다. 약관 동의 화면으로 리다이렉트합니다.");
            // 카카오 SDK 300
            Airbridge.Airbridge.event.send(Airbridge.SignUpEvent(
                user: Airbridge.User(id: userId, email: userEmail, attributes: {
              "provider": "kakao",
            })));
            await FirebaseAnalytics.instance.logSignUp(signUpMethod: "kakao");
          }
          Navigator.pushNamedAndRemoveUntil(
              context, '/termscheck', (route) => false);
        } else {
          print("${code} else code");
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

  Widget _appleloginSDK() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(width: 1.0, color: Colors.white),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 20)),
      onPressed: () async {
        await exampleForAmplitude();
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        print(credential);
        //   webAuthenticationOptions: WebAuthenticationOptions(
        //     // TODO: Set the `clientId` and `redirectUri` arguments to the values you entered in the Apple Developer portal during the setup
        //     clientId: 'de.lunaone.flutter.signinwithappleexample.service',

        //     redirectUri:
        //         // For web your redirect URI needs to be the host of the "current page",
        //         // while for Android you will be using the API server that redirects back into your app via a deep link
        //         kIsWeb
        //             ? Uri.parse('https://www.chocobread.shop/auth/apple')
        //             : Uri.parse(
        //                 'https://flutter-sign-in-with-apple-example.glitch.me/callbacks/sign_in_with_apple',
        //               ),
        //   ),
        //   // TODO: Remove these if you have no need for them
        //   nonce: 'example-nonce',
        //   state: 'example-state',
        // );

        // // ignore: avoid_print
        // print(credential);

        // // This is the endpoint that will convert an authorization code obtained
        // // via Sign in with Apple into a session in your system
        // final signInWithAppleEndpoint = Uri(
        //   scheme: 'https',
        //   host: 'flutter-sign-in-with-apple-example.glitch.me',
        //   path: '/sign_in_with_apple',
        //   queryParameters: <String, String>{
        //     'code': credential.authorizationCode,
        //     if (credential.givenName != null)
        //       'firstName': credential.givenName!,
        //     if (credential.familyName != null)
        //       'lastName': credential.familyName!,
        //     'useBundleId': !kIsWeb && (Platform.isIOS || Platform.isMacOS)
        //         ? 'true'
        //         : 'false',
        //     if (credential.state != null) 'state': credential.state!,
        //   },
        // );

        // final session = await http.Client().post(
        //   signInWithAppleEndpoint,
        // );

        // If we got this far, a session based on the Apple ID credential has been created in your system,
        // and you can now set this as the app's session
        // ignore: avoid_print
        //print(session);
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

  Widget _home() {
    return TextButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) {
            return const App();
          }));
        },
        child: const Text(
          "회원가입 하지 않고 둘러보기",
          style: TextStyle(
              color: Colors.white, decoration: TextDecoration.underline),
        ));
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
              _appleloginSDK(),
              const SizedBox(
                height: 10,
              ),
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

  Future<void> exampleForAmplitude() async {
    // Create the instance
    final Amplitude analytics =
        Amplitude.getInstance(instanceName: "chocobread");

    // Initialize SDK
    analytics.init("85f89c7ec257835fd0e2bc4d83428f4f");

    // Log an event
    analytics.logEvent('MyApp startup',
        eventProperties: {'friend_num': 10, 'is_heavy_user': true});
  }

  //카카오SDK api 연결 함수
  Future<Map<String, dynamic>> kakaoSdkLogin(
      String kakaoNumber, String? email) async {
    String tmpUrl = 'https://www.chocobread.shop/auth/kakaosdk/signup';
    var url = Uri.parse(
      tmpUrl,
    );

    Map data = {"kakaoNumber": kakaoNumber, "email": email};
    var body = json.encode(data);
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    print("kakaoSdkLogin의 response : ${list}");
    if (list['code'] != 500) {
      print("code : ${list['code']}");
      print("result의 accessToken값 : ${list['result']['accessToken']}");
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('userToken', list['result']['accessToken']);
    }
    code = list['code'];
    userId = list['result']['id'].toString();
    userEmail = list['result']['email'].toString();

    return list;
  }
}
