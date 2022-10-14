import 'dart:async';
import 'dart:convert';
import 'package:chocobread/page/nicknameset.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/app.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

//test comment
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // static String routeName = "/splash";

  void checkStatus() async {
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // getInstance로 기기 내 shared_prefs 객체를 가져온다.

    // prefs.clear();
    // TODO : 닉네임 설정 완료 여부를 확인하는 API를 호출하는 부분
    String? range = prefs.getString('range');
    if (range == null) {
      prefs.setString('range', 'loc2');
      print('range의 값이 null입니다. range를 loc2로 설정하였습니다');
    }
    String? userToken = prefs.getString("userToken");

    // FCM 토큰
    final fcmToken = await FirebaseMessaging.instance.getToken();
    print("[*]SPLASH 에서 이 기기의 fcmToken = ${fcmToken}");
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, // Required to display a heads up notification
      badge: true,
      sound: true,
    );

    print("[*] Notification Settings ${settings}");
    await saveTokenToDynamo(fcmToken!);
    print("[*] FCM Token 저장이 완료되었습니다.");

    FirebaseMessaging.instance.onTokenRefresh
    .listen((fcmToken) {
      saveTokenToDynamo(fcmToken);
    })
    .onError((err) {
      // Error getting token.
    });


    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Splash : User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('Splash : User granted provisional permission');
    } else {
      print('Splash : User declined or has not accepted permission');
    }

    if (userToken != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(userToken);

      String userId = payload['id'].toString();

      String tmpUrl = 'https://www.chocobread.shop/users/check/' + userId;
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.get(url);
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      print("splash에서의 list : ${list}");
      if (list['code'] == 200) {
        print("코드가 200입니다. 홈화면으로 리다이렉트합니다.");

        //로컬스토리지 loc 123을 채우는 코드
        String? loc3 = prefs.getString("loc3");
        if (loc3 == null || loc3 == "null") {
          print("loc3 is null");
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
            prefs.setString("loc3", "위치를 알 수 없는 사용자입니다");
            print(
                "loc3를 db에서 가져오려했으나 null입니다. 현재 로컬 스토리지에 저장된 loc3는 ${prefs.getString('loc3')}입니다");
          } else {
            prefs.setString("loc1", list['result']['loc1']);
            prefs.setString("loc2", list['result']['loc2']);
            prefs.setString("loc3", list['result']['addr']);
            currentLocation = prefs.getString("loc3");
            print(
                "loc1,2,3을 db에서 가져왔습니다. 현재 로컬 스토리지에 저장된 loc3은 ${prefs.getString('loc3')}입니다");
          }
          print("스플래시에서 loc 123채우기 완료");
        } else {
          currentLocation = prefs.getString("loc3");
        }
        //태현 : 홈 화면으로 리다이렉트. 즉 재로그인
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (BuildContext context) => const App()),
            (route) => false);
      } else if (list['code'] == 300 || list['code'] == 404) {
        print("코드가 ${list['code']}입니다. 약관동의 화면으로 리다이렉트합니다.");
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

  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      // clearSharedPreferences(); // sharedPreferences 초기화 위해 사용하는 함수
      checkStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Container(
        color: ColorStyle.mainColor,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/logo/mylogo.jpeg",
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
          ],
        ));
  }

  Future<void> saveTokenToDynamo(String fcmToken) async {
    print("saveTokenToDyanmostart");
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    if (token != null) {
      try{
        Map<String, dynamic> payload = Jwt.parseJwt(token);
        String userId = payload['id'].toString();
        var userToken = prefs.getString("userToken");
        DateTime now = DateTime.now();
        var epochTime = now.millisecondsSinceEpoch / 1000;
        const expireTime = 5260000;
        Map jsonBody = {
          "userId": userId,
          "fcmToken" : fcmToken,
          "createTime" : epochTime,
          "deleteTime" : epochTime + expireTime,
        };
        var encodedBody = json.encode(jsonBody);
        String targetUrl = 'https://d3wcvzzxce.execute-api.ap-northeast-2.amazonaws.com/tokens';
        var url = Uri.parse(
          targetUrl,
        );
        var response = await http.put(url,
            body: encodedBody);
        String responseBody = utf8.decode(response.bodyBytes);
        Map<String, dynamic> list = jsonDecode(responseBody);
        print("fcm Store reponse list ${list}");
        if (list.length == 0) {
          print("length of list is 0");
        } else {
          print("fcm Store reponse list");
        }
      }catch(error){
        print("dynamoDB store ${error}");
      }
    }
  }
}
