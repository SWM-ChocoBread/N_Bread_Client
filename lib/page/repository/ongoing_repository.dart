class OngoingRepository {
  List<Map<String, dynamic>> dataOngoing = [
    {
      "cid": "0",
      "DealImages": [
        {"dealImage": "assets/images/maltesers.png"}
      ],
      "title": "몰티져스 60개입 20개씩 소분 판매",
      "link": "https://www.coupang.com",
      "totalPrice": "16490",
      "personalPrice": "5500",
      "createdAt": "2022-07-17T05:22:12.000Z",
      "currentMember": "1",
      "totalMember": "3",
      "status": "모집중",
      "date": "2022.05.07.토 16:45",
      "place": "진선여고 앞",
      "sellerNickname": "역삼동 은이님",
      "sellerAddress": "역삼 2동",
      "contents": "몰티져스 소분 구매하실 분 찾습니다! \n매너 거래 원합니다!",
      "mystatus": "제안",
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
      "createdAt": "2022-07-17T05:22:12.000Z",
      "currentMember": "2",
      "totalMember": "4",
      "status": "모집중",
      "date": "2022.07.08.금 17:08",
      "place": "역삼역 5번 출구 앞",
      "sellerNickname": "역삼동 kth",
      "sellerAddress": "역삼 2동",
      "contents": "",
      "mystatus": "참여",
    },
    {
      "cid": "3",
      "DealImages": [
        {"dealImage": "assets/images/otg.png"}
      ],
      "title": "C타입 젠더 USB A TO C OTG 변환젠더 연결",
      "link":
          "https://smartstore.naver.com/storylink/products/2462201862?NaPm=ct%3Dl5hpo37s%7Cci%3Da113ed95c0c49c68e1291afd59ba4f422b5b63dc%7Ctr%3Dslsl%7Csn%3D190552%7Chk%3D81d2f4e60f796cde24ba88d657db89fd302578a8",
      "personalPrice": "12000",
      "createdAt": "2022-07-17T05:22:12.000Z",
      "currentMember": "10",
      "totalMember": "10",
      "status": "모집완료",
      "date": "2022.07.15.금 19:00",
      "place": "올리브영 선릉아이타워점",
      "sellerNickname": "역삼동 kth",
      "sellerAddress": "역삼 2동",
      "mystatus": "참여",
    },
    {
      "cid": "7",
      "DealImages": [
        {"dealImage": "assets/images/xexymix.png"}
      ],
      "title": "젝시믹스 블랙라벨 시그니처 380N 레깅스 1+1",
      "link":
          "https://www.xexymix.com/shop/shopdetail.html?branduid=2060991&xcode=006&mcode=002&scode=&special=7&GfDT=bm14W1w%3D",
      "personalPrice": "29500",
      "createdAt": "2022-07-17T05:22:12.000Z",
      "currentMember": "2",
      "totalMember": "2",
      "status": "모집완료",
      "date": "2022.07.05.화 11:00",
      "place": "인터밸리 푸드코트 앞",
      "sellerNickname": "역삼동 kite",
      "sellerAddress": "역삼 2동",
      "mystatus": "제안",
    }
  ];

  Future<List<Map<String, dynamic>>> loadOngoing() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return dataOngoing;
  }
}
