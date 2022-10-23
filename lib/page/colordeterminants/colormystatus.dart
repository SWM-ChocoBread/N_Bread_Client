import 'package:flutter/material.dart';

import '../../style/colorstyles.dart';

colorMyStatusBack(String mystatus) {
  // my page 안에서 현재 나의 상태가 제안 혹은 참여인 경우의 배경 색을 결정하는 function
  switch (mystatus) {
    case "제안":
      return ColorStyle.seller; // 제안하는 경우의 색
    case "참여":
      return ColorStyle.participant; // 참여하는 경우의 색
  }
  return ColorStyle.mainColor;
}

colorMyStatusText(String mystatus) {
  // my page 안에서 현재 나의 상태가 제안 혹은 참여인 경우의 텍스트 색을 결정하는 function
  switch (mystatus) {
    case "제안":
      return ColorStyle.sellerText; // 제안하는 경우의 색
    case "참여":
      return ColorStyle.participantText; // 참여하는 경우의 색
  }
  return ColorStyle.mainColor;
}
