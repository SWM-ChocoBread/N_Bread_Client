import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:chocobread/page/detail.dart';
import 'package:chocobread/page/mypage.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/page/app.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../repository/contents_repository.dart';
import 'package:uni_links/uni_links.dart';

bool doLogin = true;

//test comment
class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  // static String routeName = "/splash";
  ContentsRepository contentsRepository = ContentsRepository();
  List<Map<String, dynamic>> dataForSharedUser = [];

  // void _handleDynamicLink(Uri deepLink) async {
  //   String? code = deepLink.queryParameters['id'];
  //   if (code != null) {
  //     print('deep link 로부터 받은 코드는 ${code}입니다.');
  //     print("loadContents on splash");
  //     dataForSharedUser = await contentsRepository.loadContentsFromLocation();
  //     print("loadContents done");
  //     print('data for share user = ${dataForSharedUser}');
  //     Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(
  //             builder: (BuildContext context) => DetailContentView(
  //                   data: dataForSharedUser[int.parse(code)],
  //                   isFromHome: true,
  //                 )),
  //         (route) => false);
  //   }
  // }

  Future<void> getDeepLink() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    print('오프라인에서 deepLink 수신');

    //계획 :
    // 아이폰 오프라인 딥링크 -> 약관동의
    // 갤럭시 오프라인 딥링크 -> 로그인
    // 백그라운드 딥링크 -> 약관동의

    //아이폰 오프라인 딥링크 인식. 약관동의 화면 이동
    final String? deepLink = await getInitialLink();
    print('deep link is ${deepLink}');
    if (deepLink != null) {
      print('getInitial Link에서 deeplink는 null이 아닙니다. 약관 동의로 이동합니다.');
      PendingDynamicLinkData? dynamicLinkData = await FirebaseDynamicLinks
          .instance
          .getDynamicLink(Uri.parse(deepLink));
      if (dynamicLinkData != null) {
        Navigator.pushNamedAndRemoveUntil(
            context, '/termscheck', (route) => false);
        //_handleDynamicLink(dynamicLinkData.link);
      }
    } else {
      print("getInitial Link에서 deep link가 null이므로 아무 일도 일어나지 않습니다");
    }

    //안드로이드 오프라인 딥링크 인식. 로그인 화면 이동
    final PendingDynamicLinkData? initialLink =
        await FirebaseDynamicLinks.instance.getInitialLink();
    print("initial link");
    if (initialLink != null) {
      final Uri deepLink = initialLink.link;
      //_handleDynamicLink(deepLink);
      // Example of using the dynamic link to push the user to a different screen
      print('오프라인에서 deepLink 수신');
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      //아이폰, 안드로이드 deepLink 수신. 마이페이지 이동(근데 안됨)
      FirebaseDynamicLinks.instance.onLink.listen((dynamicLinkData) async {
        print('백그라운드에서 deepLink 수신');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPage()),
        );
        setState(() {
          doLogin = false;
        });

        print('doLogin : ${doLogin}');
        //_handleDynamicLink(dynamicLinkData.link);
      }).onError((error) {
        print('딥링크 인식 중 에러 발생');
        // Handle errors
      });
    }
  }

  void checkStatus() async {
    await getDeepLink();
    SharedPreferences prefs = await SharedPreferences
        .getInstance(); // getInstance로 기기 내 shared_prefs 객체를 가져온다.
    if (doLogin) {
      // prefs.clear();
      // TODO : 닉네임 설정 완료 여부를 확인하는 API를 호출하는 부분
      print("range 채우기");
      String? range = prefs.getString('range');
      if (range == null) {
        prefs.setString('range', 'loc2');
        print('range의 값이 null입니다. range를 loc2로 설정하였습니다');
      }
      String? userToken = prefs.getString("userToken");

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
          Navigator.pushNamedAndRemoveUntil(
              context, '/login', (route) => false);
        }
      } else {
        //토큰이 로컬 스토리지에 없으면 로그인 화면으로 이동.
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      print("[*] 유저 토큰 : " + userToken.toString());
    }
  }

  //dynamic link 처리를 위한 코드

  @override
  void initState() {
    super.initState();
    checkStatus();
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
}
