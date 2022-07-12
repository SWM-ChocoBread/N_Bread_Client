class OngoingRepository {
  List<Map<String, String>> dataOngoing = [
    {
      "cid": "0",
      "date": "2022.05.07.토 16:45",
      "title": "몰티져스 60개입 20개씩 소분 판매",
      "price": "5500",
      "current": "1",
      "total": "3",
      "status": "모집중",
      "place": "진선여고 앞",
      "mystatus": "제안",
    },
    {
      "cid": "1",
      "date": "2022.07.08.금 17:08",
      "title": "코스트코 가염버터 4개입 1개씩 소분 판매",
      "price": "5000",
      "current": "2",
      "total": "4",
      "status": "모집중",
      "place": "역삼역 5번 출구 앞",
      "mystatus": "참여",
    },
    {
      "cid": "3",
      "date": "2022.07.15.금 19:00",
      "title": "C타입 젠더 USB A TO C OTG 변환젠더 연결",
      "price": "12000",
      "current": "10",
      "total": "10",
      "status": "모집완료",
      "place": "올리브영 선릉아이타워점",
      "mystatus": "참여",
    },
    {
      "cid": "7",
      "date": "2022.07.17.일 13:00",
      "title": "내가 사고 싶은 물건들2",
      "price": "가격을 써보자 10000",
      "current": "3",
      "total": "5",
      "status": "모집중",
      "place": "파리바게트 선릉아이타워점",
      "mystatus": "제안",
    }
  ];

  Future<List<Map<String, String>>> loadOngoing() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return dataOngoing;
  }
}
