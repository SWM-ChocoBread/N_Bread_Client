import 'package:flutter/material.dart';

import '../../style/colorstyles.dart';

colorUserStatusBack(String userstatus) {
  // detail page의
  switch (userstatus) {
    case "제안자": // 제안자의 색
      return ColorStyle.seller;
    // Colors.red;
    case "참여자": // 참여자의 색
      return ColorStyle.participant;
    // Colors.blue;
  }
  return Colors.grey; // 지나가는 사람의 색
}

colorUserStatusText(String userstatus) {
  // detail page의
  switch (userstatus) {
    case "제안자": // 제안자의 색
      return ColorStyle.sellerText;
    // Colors.red;
    case "참여자": // 참여자의 색
      return ColorStyle.participantText;
    // Colors.blue;
  }
  return Colors.white; // 지나가는 사람의 색
}
