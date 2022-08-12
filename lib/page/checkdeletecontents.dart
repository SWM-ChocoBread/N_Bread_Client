import 'package:flutter/material.dart';

import 'app.dart';

class CheckQuit extends StatefulWidget {
  CheckQuit({Key? key}) : super(key: key);

  @override
  State<CheckQuit> createState() => _CheckQuitState();
}

class _CheckQuitState extends State<CheckQuit> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("글을 삭제하시겠습니까?"),
      content: const Text("제안하신 글이 삭제됩니다."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () {
              // Navigator.push(context,
              //     MaterialPageRoute(builder: (BuildContext context) {
              //   return const App();
              // }));
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => const App()),
                  (route) => false);
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
            },
            child: const Text("확인"))
      ],
    );
  }
}
