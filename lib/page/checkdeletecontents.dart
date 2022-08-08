import 'package:flutter/material.dart';

import 'app.dart';

class CheckDeleteContents extends StatefulWidget {
  CheckDeleteContents({Key? key}) : super(key: key);

  @override
  State<CheckDeleteContents> createState() => _CheckDeleteContentsState();
}

class _CheckDeleteContentsState extends State<CheckDeleteContents> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("글을 삭제하시겠습니까?"),
      // content: const Text("지금까지 작성하신 글이 저장되지 않습니다."),
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
              int count = 0;
              Navigator.of(context).popUntil((_) => count++ >= 2);
            },
            child: const Text("확인"))
      ],
    );
  }
}
