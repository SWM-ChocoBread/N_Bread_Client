import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';

class ColorStyle {
  static const mainColor = Color(
      0xff703ACF); // 0xffB19FF9(purple), 0xff478C5C(green), 0xffF6BD60(yellow), 0xffC088F3(purple)
  static const darkMainColor = Color(0xff4F476F); // 0xff013A20(green)
  static const lightMainColor =
      Color(0xff9C80EA); // 0xff9C80EA(purple), 0xffBACC81(green)
  static const extraLightMainColor = Color(0xffefe9ff);
  static const myGrey =
      Color.fromARGB(255, 240, 238, 242); // 0xfff5f3f6, 0xffe8e4ec

  static const certificated = Color(0xffFF6464);

  static const myRed = Color(0xffE43D40); // 0xffFF8882
  static const myOrange = Color(0xffFFB067);
  static const myYellow = Color(0xffFDB750);
  static const myGreen = Color(0xffE4E69B);
  static const myBlue = Color(0xffA9CEE8); // 0xff54A2D2

  // 모집중 배경색 : 0xff9EBAD3(tone-down blue), 0xff9DCED0(skyblue)
  static const ongoing = Color(0xffF5EFFF);
  // 모집중 텍스트 색
  static const ongoingText = Color(0xff703ACF);

  // 모집완료 배경색 : 0xff2D1674(dark-purple), 0xffA98AB0(light-purple)
  static const recruitcomplete = Color(0xff2D1674);
  // 모집완료 텍스트 색
  static const recruitcompleteText = Color(0xff2D1674);

  // 모집실패 배경색 : 0xff9271C2(normal-purple), 0xff8EA350(olive-green), 0xffF36870(salmon)
  static const fail = Color(0xffEFF7FF);
  // 모집실패 텍스트 색
  static const failText = Color(0xff6976EB);

  // 거래완료 배경색
  static const dealcomplete = Colors.grey;
  // 거래완료 텍스트 색
  static const dealcompleteText = Colors.white;

  // 제안자 배경색 : 0xffA4B53B(lime green), 0xff5FC9DA(light blue)
  static const seller = Color(0xffffefef);
  // 제안자 텍스트 색
  static const sellerText = Color(0xffEB6969);
  // 참여자 배경색 : 0xff29660C(kelly green), 0xffFBBC54(yellow)
  static const participant = Color.fromARGB(255, 232, 243, 227);
  // 참여자 텍스트 색
  static const participantText = Color(0xff29660C);
}
