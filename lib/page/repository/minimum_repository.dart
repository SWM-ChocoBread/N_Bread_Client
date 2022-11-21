import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Minimum{
  Map dataMinimumAPI = {
    "code": 200,
    "message": "성공",
    "isSuccess": true,
    "result": [
      {
        "title": "동원 참치",
        "link": "",
        "image":
            "https://nbreadimg.s3.ap-northeast-2.amazonaws.com/original/1666612240288_KakaoTalk_Photo_2022-10-24-20-27-21.jpeg",
        "lprice": 5000,
        "hprice": "",
        "mallName": "N빵",
        "productId": "28870807266",
        "productType": "3",
        "brand": "동원",
        "maker": "동원",
        "category1": "식품",
        "category2": "통조림/캔",
        "category3": "참치/연어",
        "category4": ""
      },
      {
        "title": "쿡담 동원참치 요리용기 125g 1개",
        "link": "https://search.shopping.naver.com/gate.nhn?id=32616712883",
        "image":
            "https://shopping-phinf.pstatic.net/main_3261671/32616712883.jpg",
        "lprice": 3350,
        "hprice": "",
        "mallName": "더싼닷컴",
        "productId": "32616712883",
        "productType": "2",
        "brand": "",
        "maker": "",
        "category1": "식품",
        "category2": "통조림/캔",
        "category3": "참치/연어",
        "category4": ""
      },
      {
        "title": "동원에프앤비 동원참치 쿡 짜글이용 100g",
        "link": "https://search.shopping.naver.com/gate.nhn?id=83399876046",
        "image":
            "https://shopping-phinf.pstatic.net/main_8339987/83399876046.jpg",
        "lprice": 3890,
        "hprice": "",
        "mallName": "보담스토어",
        "productId": "83399876046",
        "productType": "2",
        "brand": "동원",
        "maker": "동원에프앤비",
        "category1": "식품",
        "category2": "통조림/캔",
        "category3": "참치/연어",
        "category4": ""
      },
      {
        "title": "동원에프앤비 동원참치 쿡 볶음밥용 100g",
        "link": "https://search.shopping.naver.com/gate.nhn?id=20515848272",
        "image":
            "https://shopping-phinf.pstatic.net/main_2051584/20515848272.20190805151338.jpg",
        "lprice": 3950,
        "hprice": "",
        "mallName": "네이버",
        "productId": "20515848272",
        "productType": "1",
        "brand": "동원",
        "maker": "동원에프앤비",
        "category1": "식품",
        "category2": "통조림/캔",
        "category3": "참치/연어",
        "category4": ""
      },
      {
        "title": "동원에프앤비 동원참치 쿡 미역국용 100g",
        "link": "https://search.shopping.naver.com/gate.nhn?id=83399869268",
        "image":
            "https://shopping-phinf.pstatic.net/main_8339986/83399869268.jpg",
        "lprice": 3990,
        "hprice": "",
        "mallName": "보담스토어",
        "productId": "83399869268",
        "productType": "2",
        "brand": "동원",
        "maker": "동원에프앤비",
        "category1": "식품",
        "category2": "통조림/캔",
        "category3": "참치/연어",
        "category4": ""
      }
    ]
  };

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


