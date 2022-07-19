class OngoingRepository {
  List<Map<String, String>> dataOngoing = [
    {
      "cid": "0",
      "image": "assets/images/maltesers.png",
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
      "image": "assets/images/butter.png",
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
      "image": "assets/images/otg.png",
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
      "image": "assets/images/xexymix.png",
      "date": "2022.07.05.화 11:00",
      "title": "젝시믹스 블랙라벨 시그니처 380N 레깅스 1+1",
      "price": "29500",
      "current": "2",
      "total": "2",
      "status": "모집완료",
      "place": "인터밸리 푸드코트 앞",
      "mystatus": "제안",
    }
  ];

  Future<List<Map<String, String>>> loadOngoing() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return dataOngoing;
  }
}
