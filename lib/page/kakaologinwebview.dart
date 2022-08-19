import 'dart:convert';
import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:http/http.dart' as http;
import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/termscheck.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'nicknameset.dart';

class KakaoLoginWebview extends StatefulWidget {
  KakaoLoginWebview({Key? key}) : super(key: key);

  @override
  State<KakaoLoginWebview> createState() => _KakaoLoginWebviewState();
}

class _KakaoLoginWebviewState extends State<KakaoLoginWebview> {
  late InAppWebViewController _webViewController;
  CookieManager _cookieManager = CookieManager.instance();
  final myurl = Uri.parse("");

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Future<bool> checkStatus() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // getInstance로 기기 내 shared_prefs 객체를 가져온다.

    //prefs.clear();
    bool isLogin = prefs.getBool("isLogin") ??
        false; // 처음 앱을 설치했을 때, isLogin 값 자체가 저장되어 있지 않아 null일 것이므로, 이 경우 false로 가져온다.
    bool isTerms = prefs.getBool("isTerms") ?? false; // 약관에 모두 동의했는지 여부
    bool isNickname = prefs.getBool("isNickname") ?? false; // 닉네임을 설정했는지 여부

    print("[*] 로그인 상태 : " + isLogin.toString());
    print("[*] 약관동의 상태 : " + isTerms.toString());
    print("[*] 닉네임 설정 상태 : " + isNickname.toString());
    return (isTerms && isNickname);
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/termscheck', (route) => false);
      }
    });
  }

  Widget _kakaoLoginWebview() {
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://chocobread.shop/auth/kakao")),
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        //Do some checks here to decide if CANCELS or PROCEEDS
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onLoadStop: (InAppWebViewController controller, Uri? myurl) async {
        // 원래는 onLoadStop 이었다.
        print("[kakaoLoinWebview.dart] onLoadStop으로 들어왔습니다!");
        if (myurl != null) {
          print("[kakaoLoginWeview.dart] myurl은 null 이 아닙니다.");
          // List<Cookie> cookies = await _cookieManager.getCookies(url: myurl);
          Cookie? cookie =
              await _cookieManager.getCookie(url: myurl, name: "accessToken");
          print("[kakaoLoginWebview.dart] prefs 받아오기 start");
          final prefs = await SharedPreferences.getInstance();
          print(cookie);
          print("[kakaoLoginWebview.dart] prefs 받아오기 end");
          if (cookie != null) {
            print("[kakaoLoginWebview.dart] 받아온 cookie 는 null 이 아닙니다.");
            // prefs.setBool("isLogin", true);
            // print(prefs.getBool("isLogin"));
            prefs.setString("userToken", cookie.value);
            sendSignupToAirbridge();

            moveScreen();
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
    print(myurl.runtimeType);

    return Scaffold(
      appBar: _appBarWidget(),
      body: _kakaoLoginWebview(),
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
}
