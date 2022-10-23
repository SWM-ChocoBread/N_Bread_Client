import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MyChip extends StatefulWidget {
  Color color;
  Color backgroundcolor;
  String content;

  MyChip(
      {super.key,
      required this.color,
      required this.backgroundcolor,
      required this.content});

  @override
  State<MyChip> createState() => _MyChipState();
}

class _MyChipState extends State<MyChip> {
  @override
  Widget build(BuildContext context) {
    return Chip(
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      label: Text(
        widget.content,
        style: TextStyle(
            color: widget.color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
      // labelPadding: EdgeInsets.zero,
      backgroundColor: widget.backgroundcolor,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10))),
    );
  }
}
