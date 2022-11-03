import 'package:flutter/material.dart';

import '../../style/colorstyles.dart';

colorStatusBack(String status) {
  // my page 안에서 현재 거래의 상태가 모집중, 모집완료, 거래완료, 모집실패 경우의 배경 색을 결정하는 function
  switch (status) {
    case "모집중":
      return ColorStyle.ongoing; // 모집중인 경우의 색
    case "모집완료":
      return ColorStyle.recruitcomplete; // 모집완료인 경우의 색
    case "거래완료": // 거래완료인 경우의 색
      return ColorStyle.dealcomplete;
    case "모집실패":
      return ColorStyle.fail; // 모집실패인 경우의 색
  }
  return const Color(0xffF6BD60);
}

colorStatusText(String status) {
  // my page 안에서 현재 거래의 상태가 모집중, 모집완료, 거래완료, 모집실패 경우의 텍스트 색을 결정하는 function
  switch (status) {
    case "모집중":
      return ColorStyle.ongoingText; // 모집중인 경우의 색
    case "모집완료":
      return ColorStyle.recruitcompleteText; // 모집완료인 경우의 색
    case "거래완료": // 거래완료인 경우의 색
      return ColorStyle.dealcompleteText;
    case "모집실패":
      return ColorStyle.failText; // 모집실패인 경우의 색
  }
  return Colors.black;
}
