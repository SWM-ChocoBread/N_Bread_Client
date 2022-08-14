import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

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
      backgroundColor: Colors.white,
      // Colors.transparent,
    );
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
            Navigator.pushNamedAndRemoveUntil(
                context, "/termscheck", (r) => false);
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

  Future<void> setUserLocation(String latitude, String longitude) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();
      // print("setUserLocation on kakaoLogin, getTokenPayload is ${payload}");
      // print("setUserLocation was called on mypage with userId is ${userId}");

      String tmpUrl = 'https://www.chocobread.shop/users/location/' +
          userId +
          '/' +
          latitude +
          '/' +
          longitude;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.post(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      if (list.length == 0) {
        // print("length of list is 0");
      } else {
        try {
          prefs.setString(
              'userLocation', list['result']['location3'].toString());
          // print("list value is ${list['result']}");
          // print(
              // 'currnetLocation in setUserLocation Function is ${list['result']['location3'].toString()}');
          // print(list);
        } catch (e) {
          print(e);
        }
      }
    }
  }
}
