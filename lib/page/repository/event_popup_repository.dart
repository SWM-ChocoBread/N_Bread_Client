// 다시 보지 않기 여부 bool & 이 유저가 최근에 본 이벤트 id (가장 최근 추가한 이벤트 id)
// 할 때마다 API를 호출해야 한다는 문제
// 스플래시에서 항상 이 API를 호출해야 한다는 문제 발생
// DB에 저장하게 되는 경우 : DB에 부담이 가해질 것 같다. table이 하나 더
// Splash에서 이미 처리하는 로직이 많음
// Splash가 왜 오래 걸리는 지 찾아볼 것
// 요청을 보낼 때 유저가 가장 최근에 본 이벤트를 같이 보내줘야 함

// 이벤트 팝업에 들어갈 이미지를 받을 함수
// 이미지 링크, 이미지를 클릭했을 때 어디로 가야 하는지 리다이렉션 type, 상세 페이지 dealId
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

List eventBannerImages = [];

Future<Map<String, dynamic>> loadEventPopUp(String recentId) async {
  final prefs = await SharedPreferences.getInstance();
  String tmpUrl = 'https://www.chocobread.shop/events/popup/' + recentId;

  // 300 다시 보지 않기 ->
  // 400
  var url = Uri.parse(tmpUrl);
  late Map<String, dynamic> list; // 요청의 결과를 받아올 임시 리스트

  var response = await http.get(url);
  var statusCode = response.statusCode;
  var responseHeaders = response.headers;
  String responseBody = utf8.decode(response.bodyBytes);
  print("statusCode: ${statusCode}");
  print("responseHeaders: ${responseHeaders}");
  print("responseBody: ${responseBody}");
  list = jsonDecode(responseBody);

  print("loadEventPopUp called");
  print("loadEventPopUp에 의해 받아온 data : ${list['result']}");
  return list;

  // return [];
}
