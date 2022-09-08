import 'dart:convert';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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

  Future<bool> checkStatus() async {
    //prefs.clear();
    // TODO : 닉네임을 설정 완료 했는지 여부를 확인하는 API 호출
    bool isNickname = true;
    print("[*] 닉네임 설정 상태 : " + isNickname.toString());
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
        Navigator.pushNamedAndRemoveUntil(
            context, '/termscheck', (route) => false);
      }
    });
  }

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
          if (cookie != null) {}
          // print("start");
          final prefs = await SharedPreferences.getInstance();
          // print(cookie);
          // print("end");
          if (cookie != null) {
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
}
