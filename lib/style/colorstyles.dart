import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ColorStyle {
  static const mainColor = Color(
      0xff703ACF); // 0xffB19FF9(purple), 0xff478C5C(green), 0xffF6BD60(yellow), 0xffC088F3(purple)
  static const darkMainColor = Color(0xff4F476F); // 0xff013A20(green)
  static const lightMainColor =
      Color(0xff9C80EA); // 0xff9C80EA(purple), 0xffBACC81(green)
  static const extraLightMainColor = Color(0xffCDD193);
  static const myGrey =
      Color.fromARGB(255, 240, 238, 242); // 0xfff5f3f6, 0xffe8e4ec

  static const myRed = Color(0xffE43D40); // 0xffFF8882
  static const myOrange = Color(0xffFFB067);
  static const myYellow = Color(0xffFDB750);
  static const myGreen = Color(0xffE4E69B);
  static const myBlue = Color(0xffA9CEE8); // 0xff54A2D2

  static const ongoing = Color(
      0xff703ACF); // 모집중 색 : 0xff9EBAD3(tone-down blue), 0xff9DCED0(skyblue)
  static const recruitcomplete = Color(
      0xff2D1674); // 모집완료 색 : 0xff2D1674(dark-purple), 0xffA98AB0(light-purple)
  static const fail = Color(
      0xffC55FFC); // 모집실패 색 : 0xff9271C2(normal-purple), 0xff8EA350(olive-green), 0xffF36870(salmon)
  static const dealcomplete = Colors.grey; // 거래완료 색

  static const seller = Color(
      0xffA4B53B); // 제안자 색 : 0xffA4B53B(lime green), 0xff5FC9DA(light blue)
  static const participant =
      Color(0xff29660C); // 참여자 색 : 0xff29660C(kelly green), 0xffFBBC54(yellow)
}
