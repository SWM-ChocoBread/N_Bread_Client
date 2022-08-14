import 'dart:convert';
import 'dart:io';
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/login.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:chocobread/page/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class KakaoLogoutWebview extends StatefulWidget {
  KakaoLogoutWebview({Key? key}) : super(key: key);

  @override
  State<KakaoLogoutWebview> createState() => _KakaoLogoutWebviewState();
}

class _KakaoLogoutWebviewState extends State<KakaoLogoutWebview> {
  late InAppWebViewController _webViewController;
  CookieManager _cookieManager = CookieManager.instance();
  final myurl = Uri.parse(""); // https://www.chocobread.shop/auth/kakao/logout
  late int count;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    count = 0;
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> checkStatus() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // getInstance로 기기 내 shared_prefs 객체를 가져온다.

    //prefs.clear();
    prefs.setBool("isLogin",
        false); // 처음 앱을 설치했을 때, isLogin 값 자체가 저장되어 있지 않아 null일 것이므로, 이 경우 false로 가져온다.
  }

  void moveScreen() async {
    await Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context) => Login()),
        (route) => false);
  }

  Widget _kakaoLogoutWebview() {
    checkStatus();
    return InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(
            // "https://www.chocobread.shop/auth/kakao/logout"
            "https://kauth.kakao.com/oauth/logout?client_id=961455942bafc305880d39f2eef0bdda&logout_redirect_uri=https://www.chocobread.shop/auth/kakao/logout")),
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          //Do some checks here to decide if CANCELS or PROCEEDS
          return ServerTrustAuthResponse(
              action: ServerTrustAuthResponseAction.PROCEED);
        },
        onLoadStop: (InAppWebViewController controller, Uri? myurl) async {
          // 원래는 onLoadStop 이었다.
          print("[kakaoLogout.dart] onLoadStop으로 들어왔습니다!");
          if (myurl != null) {
            print("[kakaoLogout.dart] myurl은 null 이 아닙니다.");
            Cookie? cookie =
                await _cookieManager.getCookie(url: myurl, name: "accessToken");
            print("[kakaoLogout.dart] prefs 받아오기 start");
            final prefs = await SharedPreferences.getInstance();
            print(cookie);
            count += 1;
            print("[kakaoLogout.dart] prefs 받아오기 end");
            if (cookie != null || count == 2) {
              print("[kakaoLogout.dart] 받아온 cookie 는 null 이 아닙니다.");
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (BuildContext context) {
              //   return Login();
              // }));
              // SystemNavigator.pop();
              // exit(0);
              // moveScreen();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => Login()),
                  (route) => false);
              print("[kakaoLogout.dart] 로그인 화면으로 이동했을까요?");
            }
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    print(myurl.runtimeType);

    return Scaffold(
      appBar: _appBarWidget(),
      body: _kakaoLogoutWebview(),
    );
  }
}
