import '../../style/colorstyles.dart';

colorStatusDoneBack(String currentMember, String totalMember) {
  if ((int.parse(currentMember) + 1) < int.parse(totalMember)) {
    // 모집중인 경우의 배경색
    return ColorStyle.ongoing;
  } else if ((int.parse(currentMember) + 1) == int.parse(totalMember)) {
    // 모집완료인 경우의 배경색
    return ColorStyle.recruitcomplete;
  } else {
    return ColorStyle.mainColor;
  }
}

colorStatusDoneText(String currentMember, String totalMember) {
  if ((int.parse(currentMember) + 1) < int.parse(totalMember)) {
    // 모집중인 경우의 텍스트 색
    return ColorStyle.ongoingText;
  } else if ((int.parse(currentMember) + 1) == int.parse(totalMember)) {
    // 모집완료인 경우의 텍스트 색
    return ColorStyle.recruitcompleteText;
  } else {
    return ColorStyle.mainColor;
  }
}
