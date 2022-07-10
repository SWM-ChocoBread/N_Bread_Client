class ContentsRepository {
  Map<String, dynamic> data = {
    "yeoksam": [
      {
        "cid": "0", //
        "image": "assets/images/maltesers.png",
        "title": "몰티져스 60개입 20개씩 소분 판매",
        "link": "https://www.coupang.com",
        "price": "5500",
        "written": "18초 전",
        "current": "1",
        "total": "3",
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
        "price": "5000",
        "written": "3분 전",
        "current": "1",
        "total": "4",
        "status": "모집중",
        "date": "2022.07.08.금 17:08",
        "place": "역삼역 5번 출구 앞",
        "sellerNickname": "역삼동 kth",
        "sellerAddress": "역삼 2동",
      },
      {
        "cid": "2",
        "image": "assets/images/flipflop.jpeg",
        "title": "아키클래식 클라우드 리커버리 플립플랍",
        "price": "27500",
        "written": "11분 전",
        "current": "1",
        "total": "2",
        "status": "모집중",
        "date": "2022.07.12.화 19:00",
        "place": "아남타워 앞"
      },
    ],
    "bangbae": [
      {
        "cid": "3",
        "image": "assets/images/maltesers.png",
        "title": "[방배] 몰티져스 60개입 20개씩 소분 판매",
        "price": "5500",
        "written": "18초 전",
        "current": "1",
        "total": "3",
        "status": "모집중",
        "date": "2022.05.07.토 16:45",
        "place": "진선여고 앞"
      },
      {
        "cid": "4",
        "image": "assets/images/butter.png",
        "title": "[방배] 코스트코 가염버터 4개입 1개씩 소분 판매",
        "price": "5000",
        "written": "3분 전",
        "current": "1",
        "total": "4",
        "status": "모집중",
        "date": "2022.07.08.금 17:08",
        "place": "역삼역 5번 출구 앞"
      },
      {
        "cid": "5",
        "image": "assets/images/flipflop.jpeg",
        "title": "[방배] 아키클래식 클라우드 리커버리 플립플랍",
        "price": "27500",
        "written": "11분 전",
        "current": "1",
        "total": "2",
        "status": "모집중",
        "date": "2022.07.12.화 19:00",
        "place": "아남타워 앞"
      },
    ],
  };

  Future<List<Map<String, String>>> loadContentsFromLocation(
      String location) async {
    // API 통신 location 값을 보내주면서
    await Future.delayed(const Duration(milliseconds: 1000));
    return data[location];
  }
}
