import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class OngoingRepository {
  List<Map<String, String>> dataOngoing = [
    {
      "cid": "0",
      "image": "assets/images/maltesers.png",
      "date": "2022.05.07.토 16:45",
      "title": "몰티져스 60개입 20개씩 소분 판매",
      "personalPrice": "5500",
      "currentMember": "1",
      "totalMember": "3",
      "status": "모집중",
      "place": "진선여고 앞",
      "mystatus": "제안",
    },
    {
      "cid": "1",
      "image": "assets/images/butter.png",
      "date": "2022.07.08.금 17:08",
      "title": "코스트코 가염버터 4개입 1개씩 소분 판매",
      "personalPrice": "5000",
      "currentMember": "2",
      "totalMember": "4",
      "status": "모집중",
      "place": "역삼역 5번 출구 앞",
      "mystatus": "참여",
    },
    {
      "cid": "3",
      "image": "assets/images/otg.png",
      "date": "2022.07.15.금 19:00",
      "title": "C타입 젠더 USB A TO C OTG 변환젠더 연결",
      "personalPrice": "12000",
      "currentMember": "10",
      "totalMember": "10",
      "status": "모집완료",
      "place": "올리브영 선릉아이타워점",
      "mystatus": "참여",
    },
    {
      "cid": "7",
      "image": "assets/images/xexymix.png",
      "date": "2022.07.05.화 11:00",
      "title": "젝시믹스 블랙라벨 시그니처 380N 레깅스 1+1",
      "personalPrice": "29500",
      "currentMember": "2",
      "totalMember": "2",
      "status": "모집완료",
      "place": "인터밸리 푸드코트 앞",
      "mystatus": "제안",
    }
  ];

  // Future<List<Map<String, String>>> loadOngoing() async {
  //   await Future.delayed(const Duration(milliseconds: 1000));
  //   return dataOngoing;
  // }

  Future<Map<String, dynamic>> _callAPI(String userId) async {
    String tmpUrl = 'https://www.chocobread.shop/users/deals/' + userId;
    var url = Uri.parse(
      tmpUrl,
    );
    var response = await http.get(url);
    String responseBody = utf8.decode(response.bodyBytes);
    Map<String, dynamic> list = jsonDecode(responseBody);

    //print(list);

    return list;
  }

//http://localhost:8080/users/deals/2
  Future<List<Map<String, dynamic>>> loadOngoing(String userId) async {
    // API 통신 location 값을 보내주면서
    Map<String, dynamic> getData = await _callAPI(userId);
    print("getData value");
    print(getData);
    print(getData['result']);
    await Future.delayed(const Duration(milliseconds: 1000));
    var tmp = List<Map<String, dynamic>>.empty(growable: true);
    if (getData['code'] == 401) {
      //로그인 안했을 경우 처리
    } else {
      for (int i = 0; i < getData["result"].length; i++) {
        tmp.add(getData["result"][i]);
      }
    }
    return tmp;
  }
}
