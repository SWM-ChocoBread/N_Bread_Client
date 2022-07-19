import 'package:flutter/material.dart';
import 'app.dart';

class CheckCloseDeal extends StatefulWidget {
  CheckCloseDeal({Key? key}) : super(key: key);

  @override
  State<CheckCloseDeal> createState() => _CheckCloseDealState();
}

class _CheckCloseDealState extends State<CheckCloseDeal> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("거래를 마감하시겠습니까?"),
      content: const Text("거래는 취소되지 않습니다."),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("취소")),
        TextButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return const App();
              }));
            },
            child: const Text("확인"))
      ],
    );
  }
}
