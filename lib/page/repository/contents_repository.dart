import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ContentsRepository {
  Map<String, dynamic> data = {
    "yeoksam": [
      {
        "cid": "0", //
        "image": "assets/images/maltesers.png",
        "title": "몰티져스 60개입 20개씩 소분 판매",
        "link": "https://www.coupang.com",
        "totalPrice": "16490",
        "personalPrice": "5500",
        "written": "18초 전",
        "currentMember": "1",
        "totalMember": "3",
        "status": "모집중",
        "date": "2022.05.07.토 16:45",
        "place": "진선여고 앞",
        "sellerNickname": "역삼동 은이님",
        "sellerAddress": "역삼 2동",
        "contents": "몰티져스 소분 구매하실 분 찾습니다! \n매너 거래 원합니다!",
      },
      {
        "cid": "1",
        "image": "assets/images/butter.png",
        "title": "코스트코 가염버터 4개입 1개씩 소분 판매",
        "link": "https://www.naver.com",
        "totalPrice": "19900",
        "personalPrice": "5000",
        "written": "3분 전",
        "currentMember": "2",
        "totalMember": "4",
        "status": "모집중",
        "date": "2022.07.08.금 17:08",
        "place": "역삼역 5번 출구 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
      {
        "cid": "2",
        "image": "assets/images/flipflop.jpeg",
        "title": "아키클래식 클라우드 리커버리 플립플랍",
        "link":
            "https://www.akiii.co.kr/shop/shopdetail.html?branduid=1152964&xcode=014&mcode=004&scode=013&special=3&GfDT=bmp4W10%3D",
        "personalPrice": "27500",
        "written": "11분 전",
        "currentMember": "1",
        "totalMember": "2",
        "status": "모집중",
        "date": "2022.07.12.화 19:00",
        "place": "아남타워 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
      {
        "cid": "3",
        "image": "assets/images/otg.png",
        "title": "C타입 젠더 USB A TO C OTG 변환젠더 연결",
        "link":
            "https://smartstore.naver.com/storylink/products/2462201862?NaPm=ct%3Dl5hpo37s%7Cci%3Da113ed95c0c49c68e1291afd59ba4f422b5b63dc%7Ctr%3Dslsl%7Csn%3D190552%7Chk%3D81d2f4e60f796cde24ba88d657db89fd302578a8",
        "personalPrice": "1200",
        "written": "16분 전",
        "currentMember": "10",
        "totalMember": "10",
        "status": "모집완료",
        "date": "2022.07.15.금 19:00",
        "place": "올리브영 선릉아이타워점",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
      {
        "cid": "4",
        "image": "assets/images/xexymix.png",
        "title": "젝시믹스 블랙라벨 시그니처 380N 레깅스 1+1",
        "link":
            "https://www.xexymix.com/shop/shopdetail.html?branduid=2060991&xcode=006&mcode=002&scode=&special=7&GfDT=bm14W1w%3D",
        "personalPrice": "29500",
        "written": "20일 전",
        "currentMember": "2",
        "totalMember": "2",
        "status": "거래완료",
        "date": "2022.07.05.화 11:00",
        "place": "인터밸리 푸드코트 앞",
        "sellerNickname": "역삼동 kite",
        "sellerAddress": "역삼 2동",
      },
    ],
    "bangbae": [
      {
        "cid": "10",
        "image": "assets/images/maltesers.png",
        "title": "[방배] 몰티져스 60개입 20개씩 소분 판매",
        "personalPrice": "5500",
        "written": "18초 전",
        "currentMember": "1",
        "totalMember": "3",
        "status": "모집중",
        "date": "2022.05.07.토 16:45",
        "place": "진선여고 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
      {
        "cid": "11",
        "image": "assets/images/butter.png",
        "title": "[방배] 코스트코 가염버터 4개입 1개씩 소분 판매",
        "personalPrice": "5000",
        "written": "3분 전",
        "currentMember": "1",
        "totalMember": "4",
        "status": "모집중",
        "date": "2022.07.08.금 17:08",
        "place": "역삼역 5번 출구 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
      {
        "cid": "12",
        "image": "assets/images/flipflop.jpeg",
        "title": "[방배] 아키클래식 클라우드 리커버리 플립플랍",
        "personalPrice": "27500",
        "written": "11분 전",
        "currentMember": "1",
        "totalMember": "2",
        "status": "모집중",
        "date": "2022.07.12.화 19:00",
        "place": "아남타워 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
    ],
  };

  Future<Map<String, dynamic>> _callAPI() async {
    var url = Uri.parse(
      'http://localhost:8090',
    );
    var response = await http.get(url);
    String responseBody = utf8.decode(response.bodyBytes);
    print(response.body);
    print(response.body.runtimeType);
    print(jsonDecode(responseBody).runtimeType);

    //print(responseBody[0]);

    Map<String, dynamic> list = jsonDecode(responseBody);

    // print('Response status: ${response.statusCode}');
    // print('Response body: ${response.body}');
    print(list);
    data = list;
    print(list.runtimeType);
    return list;
  }

  Future<List<Map<String, String>>> loadContentsFromLocation(
      String location) async {
    // API 통신 location 값을 보내주면서
    await _callAPI();
    await Future.delayed(const Duration(milliseconds: 1000));

    var tmp = List<Map<String, String>>.empty(growable: true);
    // print("data[lcationsdfsdfsdf]");
    // print(data[location][0].runtimeType);
    for (int i = 0; i < data[location].length; i++) {
      print("check");
      print(data[location][i].runtimeType);
      try {
        var toMap = Map<String, String>.from(data[location][i]);
        print("type of tomap");
        print(toMap.runtimeType);
         tmp.add(toMap);
      } catch (err) {
        print("에러발생");
        print(data[location][i]);
      }

      
      // Map<String, String> strr = data[location][i]
      //     .map((key, value) => MapEntry(key, value?.toString()));
      //print(strr.runtimeType);
     
    }
    //print(data[location].length);
    print(tmp);
    print(tmp.runtimeType);
    //print(jsonDecode(data[location]));
    return tmp;
  }
}
