import 'package:flutter/material.dart';

import 'app.dart';

class CheckModifyQuit extends StatefulWidget {
  CheckModifyQuit({Key? key}) : super(key: key);

  @override
  State<CheckModifyQuit> createState() => _CheckModifyQuitState();
}

class _CheckModifyQuitState extends State<CheckModifyQuit> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("글 수정을 취소하시겠습니까?"),
      content: const Text("지금까지 수정하신 글이 저장되지 않습니다."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () {
              // 글 수정을 취소하는 경우
              // 2번 뒤로 가기
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
            },
            child: const Text("확인"))
      ],
    );
  }
}
