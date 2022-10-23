import 'package:flutter/material.dart';
import '../../style/colorstyles.dart';

SnackBar MySnackBar(String text) {
  return SnackBar(
    content: Text(
      text,
      style: const TextStyle(color: Colors.white),
    ),
    backgroundColor: ColorStyle.darkMainColor,
    duration: const Duration(milliseconds: 2000),
    behavior: SnackBarBehavior.floating,
    elevation: 50,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
      Radius.circular(5),
    )),
  );
}
