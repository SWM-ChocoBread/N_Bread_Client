import 'dart:convert';

import 'package:http/http.dart' as http;

loadCatalog() async {
  String tmpUrl =
      'https://d3wcvzzxce.execute-api.ap-northeast-2.amazonaws.com/categories';
  var url = Uri.parse(tmpUrl);
  var tmp =
      List<Map<String, dynamic>>.empty(growable: true); // 요청의 결과를 받아올 임시 리스트
  late Map<String, dynamic> list;

  var response = await http.get(url);
  var statusCode = response.statusCode;
  print("[*] runtimeType : ${statusCode.runtimeType}");
  var responseHeaders = response.headers;
  String responseBody = utf8.decode(response.bodyBytes);
  print("statusCode: ${statusCode}");
  print("responseHeaders: ${responseHeaders}");
  print("responseBody: ${responseBody}");
  list = jsonDecode(responseBody);

  print("loadCatalog called");
  print("loadCatalog에 의해 받아온 data : ${list}");
  print("loadCatalog의 list[Items] : ${list["Items"]}");
  if (statusCode == 200) {
    // 해당하는 거래를 받아온 경우 : 200
    return list["Items"];
  } else {
    // 해당하는 거래가 없는 경우 : 404
    return [];
  }
}
