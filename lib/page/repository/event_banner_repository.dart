import 'dart:convert';

import 'package:http/http.dart' as http;

Future<List> loadEventBanner() async {
  String tmpUrl = '';
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

  print("loadContentByDealId called");
  print("loadContentByDealId에 의해 받아온 data : ${list}");

  return list["result"]["DealImages"];
}
