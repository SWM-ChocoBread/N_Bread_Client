import 'dart:convert';

import 'package:airbridge_flutter_sdk/airbridge_flutter_sdk.dart';
import 'package:flutter/material.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

import 'login.dart';

class CheckResign extends StatefulWidget {
  CheckResign({Key? key}) : super(key: key);

  @override
  State<CheckResign> createState() => _CheckResignState();
}

class _CheckResignState extends State<CheckResign> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("정말 탈퇴하시겠습니까?"),
      content: const Text("탈퇴하시면 N빵을 사용할 수 없습니다."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () async {
              // int count = 0;
              // Navigator.of(context).popUntil((_) => count++ >= 2);
              Airbridge.event.send(SignOutEvent());
              await resign();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => Login()),
                  (route) => false);
            },
            child: const Text("확인"))
      ],
    );
  }

  //kakao apple resign api
  Future<void> resign() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");

    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      print('payload value is ${payload}');

      String provider = payload['provider'].toString();
      print("provider is ${provider} on resign api");

      if (provider == "kakao") {
        provider = "kakaosdk";
        try {
          await UserApi.instance.unlink();
          print('연결 끊기 성공, SDK에서 토큰 삭제');
        } catch (error) {
          print('연결 끊기 실패 $error');
        }
      }

      String tmpUrl =
          'https://www.chocobread.shop/auth/' + provider + '/signout';
      print("tmpUrl value is ${tmpUrl}");
      var url = Uri.parse(
        tmpUrl,
      );
      var response = await http.delete(url, headers: {
        'Authorization': token,
        'Content-Type': 'application/x-www-form-urlencoded'
      });
      String responseBody = utf8.decode(response.bodyBytes);
      Map<String, dynamic> list = jsonDecode(responseBody);
      prefs.remove("userToken");
      print("prefs setting done");
      print(list);
      //Map<String, dynamic> list = jsonDecode(responseBody);
      // if (list.length == 0) {
      //   print("length of list is 0");
      // } else {
      //   print(list);
      // }
      Airbridge.event.send(Event(
        'User Resign',
        option: EventOption(
          attributes: {
            "userId": payload['id'].toString(),
            "provider": payload['provider'].toString(),
          },
        ),
      ));
    }
  }
}
