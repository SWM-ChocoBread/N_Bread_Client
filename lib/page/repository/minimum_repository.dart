import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Minimum {
  Future<List> loadPriceByDealId(int dealId) async {
    print("loadContentByDealId 함수 안으로 받아온 dealId는 : ${dealId}");
    String tmpUrl = 'https://www.chocobread.shop/price/$dealId';
    var url = Uri.parse(tmpUrl);
    var tmp =
        List<Map<String, dynamic>>.empty(growable: true); // 요청의 결과를 받아올 임시 리스트
    late Map<String, dynamic> list;

    var response = await http.get(url);
    var statusCode = response.statusCode;
    var responseHeaders = response.headers;
    String responseBody = utf8.decode(response.bodyBytes);
    print("statusCode: ${statusCode}");
    print("responseHeaders: ${responseHeaders}");
    print("responseBody: ${responseBody}");
    list = jsonDecode(responseBody);

    print("loadPriceByDealId called");
    print("loadPriceByDealId에 의해 받아온 data : ${list}");
    if (list['code'] == 200) {
      // 해당하는 거래를 받아온 경우 : 200
      return list["result"];
    } else {
      // 해당하는 거래가 없는 경우 : 404
      return [];
    }
  }

  //List dataMinimum = dataMinimumAPI["result"];
}