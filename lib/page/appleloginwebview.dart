import 'dart:convert';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:amplitude_flutter/amplitude.dart';
import 'package:amplitude_flutter/identify.dart';
import 'package:sendbird_sdk/sendbird_sdk.dart' as sendbird_sdk;

import 'app.dart';

class AppleLoginWebview extends StatefulWidget {
  AppleLoginWebview({Key? key}) : super(key: key);

  @override
  State<AppleLoginWebview> createState() => _AppleLoginWebviewState();
}

class _AppleLoginWebviewState extends State<AppleLoginWebview> {
  late InAppWebViewController _webViewController;
  CookieManager _cookieManager = CookieManager.instance();
  final myurl = Uri.parse("https://chocobread.shop/auth/apple/callback");

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false,
      // Colors.transparent,
    );
  }

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
      String userProvider = payload['provider'].toString();

      String tmpUrl = 'https://www.chocobread.shop/users/check/' + userId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print("splash에서의 list : ${list}");
      if (list['code'] == 200) {
        connect(userId); // connecting to sendbird

        print("코드가 200입니다. 홈화면으로 리다이렉트합니다.");
        final prefs = await SharedPreferences.getInstance();
        String? curLocation = prefs.getString("loc3");
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
            if (list['result']['addr'] == null) {
              prefs.setString("loc3", "위치를 알 수 없는 사용자입니다");
              print(
                  "loc1,2,3을 db에서 가져오려했으나 null입니다. 현재 로컬 스토리지에 저장된 loc3은 ${prefs.getString('loc3')}입니다");
            } else {
              prefs.setString("loc1", list['result']['loc1']);
              prefs.setString("loc2", list['result']['loc2']);
              prefs.setString("loc3", list['result']['addr']);
              currentLocation = prefs.getString("loc3");
              print(
                  "curLocation을 db에서 가져왔습니다. 현재 로컬 스토리지에 저장된 curLocation은 ${prefs.getString('loc3')}입니다");
            }
          } else {
            print("token is null");
            // null이면 어떻게 되는데?
          }
          //https://www.chocobread.shop/users/1
        }
        Airbridge.event.send(SignInEvent(
            user: User(id: userId, email: list['result']['email'], attributes: {
          "provider": userProvider,
          "curLocation": prefs.getString('loc3')
        })));
        await FirebaseAnalytics.instance.logLogin(loginMethod: userProvider);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const App()),
            (route) => false);
      } else if (list['code'] == 300 || list['code'] == 404) {
        print("코드가 ${list['code']}입니다. 약관동의 화면으로 리다이렉트합니다.");
        Airbridge.event.send(SignUpEvent(
            user: User(id: userId, attributes: {"provider": userProvider})));
        await FirebaseAnalytics.instance.logSignUp(signUpMethod: userProvider);
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
  //   await checkStatus().then((wasUser) {
  //     if (wasUser) {
  //       // 이전에 로그인한 기록이 있다면, 홈 화면으로 이동 (이전 stack 비우기)
  //       //태현 : 홈 화면으로 리다이렉트. 즉 재로그인
  //       Navigator.pushAndRemoveUntil(
  //           context,
  //           MaterialPageRoute(builder: (BuildContext context) => const App()),
  //           (route) => false);
  //     } else {
  //       // 이전에 로그인한 기록이 없다면, 로그인 화면으로 이동 (이전 stack 비우기)
  //       Navigator.pushNamedAndRemoveUntil(
  //         //태현 : 애플 신규 회원가입
  //           context, '/termscheck', (route) => false);
  //     }
  //   });
  // }

  Widget _appleLoginWebview() {
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://chocobread.shop/auth/apple")),
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        //Do some checks here to decide if CANCELS or PROCEEDS
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onLoadStop: (InAppWebViewController controller, Uri? myurl) async {
        // 원래는 onLoadStop 이었다.
        if (myurl != null) {
          // List<Cookie> cookies = await _cookieManager.getCookies(url: myurl);
          Cookie? cookie =
              await _cookieManager.getCookie(url: myurl, name: "accessToken");
          final prefs = await SharedPreferences.getInstance();
          if (cookie != null) {
            prefs.setString("userToken", cookie.value);
            //sendSignupToAirbridge();
            checkStatus();
            // Navigator.pushNamedAndRemoveUntil(
            //     context, "/termscheck", (r) => false);
          }
          // print("start");
          // print(cookies[0].value); // 카카오 액세스 토큰
          // print("end");

          // print(prefs.getString("userToken"));
          // cookies.forEach((cookie) {
          //   // print(cookie.name + " " + cookie.vaxlue[0]);
          //   print(cookie);
          // });
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (BuildContext context) {
          //   return TermsCheck();
          // }));
          // if (cookies[1]["name"]) {}
          // Navigator.pushNamedAndRemoveUntil(
          //     context, "/termscheck", (r) => false);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // print(myurl.runtimeType);

    return Scaffold(
      extendBodyBehindAppBar: true, // 앱 바 위에까지 침범 허용
      appBar: _appBarWidget(),
      body: _appleLoginWebview(),
    );
  }

  Future<void> sendSignupToAirbridge() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();

      String tmpUrl = 'https://www.chocobread.shop/users/' + userId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      if (list.length == 0) {
        print(list);
        print("length of list is 0");
      } else {
        try {
          String email = list['result']['email'].toString();
          String id = list['result']['id'].toString();

          print("email = ${email}");
          print("id : ${id}");

          Airbridge.event.send(SignUpEvent(
              user: User(
            id: id,
            email: email,
            phone: null,
          )));
        } catch (e) {
          print(e);
        }
      }
    }
  }

  Future<sendbird_sdk.User> connect(String userId) async {
    try {
      final sendbird = sendbird_sdk.SendbirdSdk(
          appId: "44524844-8579-440B-A05D-6B504A8C39C3");
      final user = await sendbird.connect(userId);
      return user;
    } catch (e) {
      print("connect : ERROR $e");
      throw e;
    }
  }
}
