import 'dart:convert';
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
  final myurl = Uri.parse("https://chocobread.shop/auth/success");

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _kakaoLoginWebview() {
    return InAppWebView(
      initialUrlRequest:
          URLRequest(url: Uri.parse("https://chocobread.shop/auth/kakao")),
      onReceivedServerTrustAuthRequest: (controller, challenge) async {
        // final cookieManager = CookieManager();
        // await cookieManager.deleteCookies(
        //     url: Uri.parse("https://chocobread.shop/auth/success"));
        // print("authkakao's cookie is deleted");
        // List<Cookie> cookies = await cookieManager.getCookies(
        //     url: Uri.parse("https://chocobread.shop/auth/success"));
        // print('cookie value is');
        // print(cookies);
        //Do some checks here to decide if CANCELS or PROCEEDS
        return ServerTrustAuthResponse(
            action: ServerTrustAuthResponseAction.PROCEED);
      },
      onLoadStop: (InAppWebViewController controller, Uri? myurl) async {
        // 원래는 onLoadStop 이었다.
        if (myurl != null) {
          print("myurl ${myurl}");
          List<Cookie> cookies = await _cookieManager.getCookies(url: myurl);

          Cookie? cookie =
              await _cookieManager.getCookie(url: myurl, name: "accessToken");
          if (cookie != null) {}
          print("start");
          final prefs = await SharedPreferences.getInstance();
          print(cookie);
          print("end");
          if (cookie != null) {
            // prefs.setBool("isLogin", true);
            // print(prefs.getBool("isLogin"));
            prefs.setString("userToken", cookie.value);
            await setUserLocation("37.5037142", "127.0447821");
            print("getUserLocation called on 37.5037142,127.0447821");
            getUserLocation();
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
    print(myurl.runtimeType);

    return Scaffold(
      appBar: _appBarWidget(),
      body: _kakaoLoginWebview(),
    );
  }

  Future<void> setUserLocation(String latitude, String longitude) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);

      String userId = payload['id'].toString();
      print("setUserLocation on kakaoLogin, getTokenPayload is ${payload}");
      print("setUserLocation was called on mypage with userId is ${userId}");

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
        print("length of list is 0");
      } else {
        try {
          prefs.setString(
              'userLocation', list['result']['location3'].toString());
          print("list value is ${list['result']}");
          print(
              'currnetLocation in setUserLocation Function is ${list['result']['location3'].toString()}');
          print(list);
        } catch (e) {
          print(e);
        }
      }
    }
  }

  void getUserLocation() async {
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
      print(
          "isSuccess의 값은 ${list['isSuccess']} & ${list['isSuccess'].runtimeType}");
      if (list['isSuccess'] == true) {
        prefs.setString("userLocation", list['result']['addr']);
        print(
            'set user location done and user location is ${prefs.getString('userLocation')}');
      }
      if (list.length == 0) {
        print("length of list is 0");
      } else {
        print(list);
      }
    }
  }
}
