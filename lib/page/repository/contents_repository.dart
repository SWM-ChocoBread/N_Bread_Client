import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

void prefTest() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('tmpUserId', '2');
  await prefs.setString('tmpUserToken',
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MiwibmljayI6IuuvuOyXsOuPmSDqs4TsoJUiLCJwcm92aWRlciI6Imtha2FvIiwiaWF0IjoxNjU4ODk5ODI1LCJpc3MiOiJjaG9jb0JyZWFkIn0.Jz2ADHd0ZaAVAzfJNUIMLRBuwvFWM0g-TRDseVOSZ3w');
  print("prefs save test");
  print(prefs.get('tmpUserId'));

  //return prefs;
}

class ContentsRepository {
  Map<String, dynamic> data = {
    "yeoksam": [
      {
        "cid": "0", //
        "DealImages": [
          {"dealImage": "assets/images/maltesers.png"}
        ],
        "title": "몰티져스 60개입 20개씩 소분 판매",
        "link": "https://www.coupang.com",
        "totalPrice": "16490",
        "personalPrice": "5500",
        "createdAt": "2022-07-30T21:30:12.000Z",
        "currentMember": "1",
        "totalMember": "3",
        "status": "모집중",
        "dealDate": "2022-05-07T16:45:00.000Z",
        "place": "진선여고 앞",
        "sellerNickname": "역삼동 은이님",
        "sellerAddress": "역삼 2동",
        "contents": "몰티져스 소분 구매하실 분 찾습니다! \n매너 거래 원합니다!",
      },
      {
        "cid": "1",
        "DealImages": [
          {"dealImage": "assets/images/butter.png"}
        ],
        "title": "코스트코 가염버터 4개입 1개씩 소분 판매",
        "link": "",
        "totalPrice": "19900",
        "personalPrice": "5000",
        "createdAt": "2022-07-30T21:22:12.000Z",
        "currentMember": "2",
        "totalMember": "4",
        "status": "모집중",
        "dealDate": "2022-07-08T17:08:00.000Z",
        "place": "역삼역 5번 출구 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
      {
        "cid": "2",
        "DealImages": [
          {"dealImage": "assets/images/flipflop.jpeg"}
        ],
        "title": "아키클래식 클라우드 리커버리 플립플랍",
        "link":
            "https://www.akiii.co.kr/shop/shopdetail.html?branduid=1152964&xcode=014&mcode=004&scode=013&special=3&GfDT=bmp4W10%3D",
        "totalPrice": "54900",
        "personalPrice": "27500",
        "createdAt": "2022-07-30T05:22:12.000Z",
        "currentMember": "1",
        "totalMember": "2",
        "status": "모집중",
        "dealDate": "2022-07-12 19:00",
        "place": "아남타워 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
      {
        "cid": "3",
        "DealImages": [],
        "title": "아키클래식 클라우드 리커버리 플립플랍",
        "link":
            "https://www.akiii.co.kr/shop/shopdetail.html?branduid=1152964&xcode=014&mcode=004&scode=013&special=3&GfDT=bmp4W10%3D",
        "totalPrice": "54900",
        "personalPrice": "27500",
        "createdAt": "2022-07-20T05:22:12.000Z",
        "currentMember": "1",
        "totalMember": "2",
        "status": "모집중",
        "dealDate": "2022-07-12 19:00",
        "place": "엄청나게 긴 장소의 이름이 들어갔을 때를 테스트하기 위한 케이스 아남타워 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
      {
        "cid": "4",
        "DealImages": [
          {"dealImage": "assets/images/otg.png"}
        ],
        "title": "C타입 젠더 USB A TO C OTG 변환젠더 연결",
        "link":
            "https://smartstore.naver.com/storylink/products/2462201862?NaPm=ct%3Dl5hpo37s%7Cci%3Da113ed95c0c49c68e1291afd59ba4f422b5b63dc%7Ctr%3Dslsl%7Csn%3D190552%7Chk%3D81d2f4e60f796cde24ba88d657db89fd302578a8",
        "totalPrice": "12000",
        "personalPrice": "1200",
        "createdAt": "2022-07-17T05:22:12.000Z",
        "currentMember": "10",
        "totalMember": "10",
        "status": "모집완료",
        "dealDate": "2022-07-15 19:00",
        "place": "올리브영 선릉아이타워점",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
      {
        "cid": "5",
        "DealImages": [],
        "title": "모집이 실패된 케이스를 테스트하기 위한 경우",
        "link":
            "https://smartstore.naver.com/storylink/products/2462201862?NaPm=ct%3Dl5hpo37s%7Cci%3Da113ed95c0c49c68e1291afd59ba4f422b5b63dc%7Ctr%3Dslsl%7Csn%3D190552%7Chk%3D81d2f4e60f796cde24ba88d657db89fd302578a8",
        "totalPrice": "7200",
        "personalPrice": "1800",
        "createdAt": "2022-07-17T05:22:12.000Z",
        "currentMember": "3",
        "totalMember": "4",
        "status": "모집실패",
        "dealDate": "2022-07-12 20:40",
        "place": "선릉 맥도날드",
        "sellerNickname": "역삼동 ㅇㅊㅇ",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
      {
        "cid": "6",
        "DealImages": [
          {"dealImage": "assets/images/xexymix.png"},
          {"dealImage": "assets/images/xexymix1.png"}
        ],
        "title": "젝시믹스 블랙라벨 시그니처 380N 레깅스 1+1",
        "link":
            "https://www.xexymix.com/shop/shopdetail.html?branduid=2060991&xcode=006&mcode=002&scode=&special=7&GfDT=bm14W1w%3D",
        "totalPrice": "59900",
        "personalPrice": "29500",
        "createdAt": "2022-07-17T05:22:12.000Z",
        "currentMember": "2",
        "totalMember": "2",
        "status": "거래완료",
        "dealDate": "2022-07-05 11:00",
        "place": "인터밸리 푸드코트 앞",
        "sellerNickname": "역삼동 kite",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
      {
        "cid": "7",
        "DealImages": [],
        "title": "머리끈 소분 판매",
        "link":
            "https://www.xexymix.com/shop/shopdetail.html?branduid=2060991&xcode=006&mcode=002&scode=&special=7&GfDT=bm14W1w%3D",
        "personalPrice": "29500",
        "createdAt": "2022-06-28T05:22:12.000Z",
        "currentMember": "3",
        "totalMember": "3",
        "status": "모집완료",
        "dealDate": "2022-07-04 10:00",
        "place": "선릉 버거킹 앞",
        "sellerNickname": "역삼동 태완킴",
        "sellerAddress": "역삼 2동",
        "contents": "",
      },
    ],
    "bangbae": [
      {
        "cid": "10",
        "DealImages": [
          {"dealImage": "assets/images/maltesers.png"}
        ],
        "title": "[방배] 몰티져스 60개입 20개씩 소분 판매",
        "personalPrice": "5500",
        "createdAt": "18초 전",
        "currentMember": "1",
        "totalMember": "3",
        "status": "모집중",
        "dealDate": "2022.05.07.토 16:45",
        "place": "진선여고 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
      {
        "cid": "11",
        "DealImages": [
          {"dealImage": "assets/images/butter.png"}
        ],
        "title": "[방배] 코스트코 가염버터 4개입 1개씩 소분 판매",
        "personalPrice": "5000",
        "createdAt": "3분 전",
        "currentMember": "1",
        "totalMember": "4",
        "status": "모집중",
        "dealDate": "2022.07.08.금 17:08",
        "place": "역삼역 5번 출구 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
      {
        "cid": "12",
        "DealImages": [
          {"dealImage": "assets/images/flipflop.jpeg"}
        ],
        "title": "[방배] 아키클래식 클라우드 리커버리 플립플랍",
        "personalPrice": "27500",
        "createdAt": "11분 전",
        "currentMember": "1",
        "totalMember": "2",
        "status": "모집중",
        "dealDate": "2022.07.12.화 19:00",
        "place": "아남타워 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
    ],
  };

  Future<Map<String, dynamic>> _callAPI(String location) async {
    prefTest();
    print("prefTest Function called");
    String tmpUrl = 'https://www.chocobread.shop/deals/all/' + location;
    var url = Uri.parse(
      tmpUrl,
    );
    var response = await http.get(url);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);
    if (list.length == 0) print("length of list is 0");
    print(list);
    return list;
  }

  // void _callAPI2() async {
  //   String uu = 'http://localhost:5005/auth/kakao';
  //   var uu2 = Uri.parse(uu);
  //   var res2 = await http.get(uu2);
  //   //String responseBody2 = utf8.decode(res2.bodyBytes);
  //   //Map<String, dynamic> tmp = jsonDecode(responseBody2);
  // }

  Future<List<Map<String, dynamic>>> loadContentsFromLocation(
      String location) async {
    // API 통신 location 값을 보내주면서
    Map<String, dynamic> getData = await _callAPI(location);

    // _callAPI2();
    await Future.delayed(const Duration(milliseconds: 1000));
    var tmp = List<Map<String, dynamic>>.empty(growable: true);
    for (int i = 0; i < getData["result"]["capsule"].length; i++) {
      tmp.add(getData["result"]["capsule"][i]);
    }
    return tmp;
  }
}
