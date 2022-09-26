import 'package:flutter/material.dart';

class AlertNoService extends StatefulWidget {
  AlertNoService({Key? key}) : super(key: key);

  @override
  State<AlertNoService> createState() => _AlertNoServiceState();
}

class _AlertNoServiceState extends State<AlertNoService> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text("현재 위치"),
      content: Text("서비스가 불가능한 지역입니다!"),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text("확인")),
      ],
    );
  }
}
