import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class CheckMoveToPhotoSettings extends StatefulWidget {
  CheckMoveToPhotoSettings({Key? key}) : super(key: key);

  @override
  State<CheckMoveToPhotoSettings> createState() =>
      _CheckMoveToPhotoSettingsState();
}

class _CheckMoveToPhotoSettingsState extends State<CheckMoveToPhotoSettings> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("모든 권한을 허용해주세요."),
      content: const Text("권한을 허용해야 사진을 업로드할 수 있습니다."),
      actions: [
        TextButton(
            onPressed: () {
              // 설정으로 이동할지 물어보는 alert dialog에서 취소를 누르면, alert dialog와 bottomsheet 모두 사라진다.
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
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
