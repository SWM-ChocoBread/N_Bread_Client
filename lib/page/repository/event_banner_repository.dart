import 'dart:convert';

import 'package:http/http.dart' as http;

// 이벤트 배너에 들어갈 이미지를 받을 함수
// 이미지 링크, 이미지를 클릭했을 때 어디로 가야 하는지 리다이렉션 type, 상세 페이지 dealId

List tempEventImages = [
  {
    // "eventImage": "assets/banners/코스트코_구매대행_배너.png",
    "eventImage":
        "https://nbreadimg.s3.ap-northeast-2.amazonaws.com/original/1665128209671_af112cdd-5037-4a12-ae83-975f0e4939bb5989351294237273237.jpg",
    "type": "detail",
    "keyId": 300
  },
  {
    // "eventImage": "assets/banners/N빵_서비스소개_배너.png",
    "eventImage":
        "https://nbreadimg.s3.ap-northeast-2.amazonaws.com/original/1665128209671_af112cdd-5037-4a12-ae83-975f0e4939bb5989351294237273237.jpg",
    "type": "detail",
    "keyId": 300
  },
];

Future<List> loadEventBanner() async {
  String tmpUrl = 'https://www.chocobread.shop/events';
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
  print("list length ${list["result"].length}");
  print("list list ${list["result"][0]["eventImage"]}");
  var imageList = List<Map<String, dynamic>>.empty(growable: true);
  for (int i = 0 ; i < list["result"].length ; i++){
    // print(list["result"][i]);
    // imageList.add(list["result"][i]);
  }
  print("loadContentByDealId called");
  print("loadContentByDealId에 의해 받아온 data : ${list["result"]}");

  return list["result"];
  return tempEventImages;
}
