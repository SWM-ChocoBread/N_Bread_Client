import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AlertErrorExitApp extends StatefulWidget {
  AlertErrorExitApp({Key? key}) : super(key: key);

  @override
  State<AlertErrorExitApp> createState() => _AlertErrorExitAppState();
}

class _AlertErrorExitAppState extends State<AlertErrorExitApp> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("알 수 없는 에러가 발생했습니다."),
      content: const Text("앱을 다시 실행해주세요!"),
      actions: [
        TextButton(
            onPressed: () {
              // 3. 확인을 누르면 강제 종료가 된다.
              if (Platform.isIOS) {
                // ios
                exit(0);
              } else {
                // android 권장 앱 exit 방법
                SystemNavigator.pop();
              }
            },
            child: const Text("확인")),
      ],
    );
  }
}
