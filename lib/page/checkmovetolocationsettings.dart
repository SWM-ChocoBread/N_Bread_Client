import 'package:chocobread/page/login.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckMoveToLocationSettings extends StatefulWidget {
  CheckMoveToLocationSettings({Key? key}) : super(key: key);

  @override
  State<CheckMoveToLocationSettings> createState() =>
      _CheckMoveToLocationSettingsState();
}

class _CheckMoveToLocationSettingsState
    extends State<CheckMoveToLocationSettings> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("모든 권한을 허용해주세요."),
      content: const Text("권한을 허용해야 앱을 사용할 수 있습니다."),
      actions: [
        TextButton(
            onPressed: () {
              // 설정으로 이동할지 물어보는 alert dialog에서 취소를 누르면, 로그인 화면으로 이동한다.
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (BuildContext context) => Login()),
                  (route) => false);
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () {
              // 설정으로 이동하기 버튼을 누른 경우, 설정으로 이동한다.
              openAppSettings();
            },
            child: const Text("설정으로 이동"))
      ],
    );
  }
}
