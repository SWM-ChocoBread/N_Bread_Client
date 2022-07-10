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
    },
    {
      "cid": "1",
      "date": "2022.07.08.금 17:08",
      "title": "코스트코 가염버터 4개입 1개씩 소분 판매",
      "price": "5000",
      "current": "1",
      "total": "4",
      "status": "모집중",
      "place": "역삼역 5번 출구 앞",
    }
  ];

  Future<List<Map<String, String>>> loadOngoing() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return dataOngoing;
  }
}
