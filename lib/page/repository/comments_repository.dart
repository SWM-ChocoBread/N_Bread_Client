class CommentsRepository {
  List<Map<String, dynamic>> dataComments = [
    {
      "id": 0,
      "content":
          "정식 오픈 기준 시점으로 최적화는 준수한 편으로, 권장 사양을 지킨다면 원활하게 플레이 가능하다. 2011년 이후에 나온 쿼드코어 이상의 CPU와 16기가 정도의 램을 갖춘 컴퓨터로도 대규모 전투를 연출한 상황에서 프레임이 조금 떨어지는 수준이다. 다만, QHD 이상 해상도에서 공식 요구사항이 극단적으로 높아지는 것을 볼수 있는데, 60프레임 완전 보장을 기준으로 설명된 것으로 추정된다. 실제 플레이 상황에선 FHD 해상도와, 모든 옵션 최상을 기준으로 6세대 이후의 인텔 CPU, 라이젠 이후의 AMD CPU와 GTX1060 정도의 사양으로도 원활한 플레이가 가능하다.",
      "isDeleted": null,
      "createdAt": "2022-07-17T05:22:12.000Z",
      "updatedAt": "2022-07-17T05:22:12.000Z",
      "deletedAt": null,
      "fromThen": "17시간 전",
      "dealId": 1,
      "userId": 1,
      "User": {"nick": "역삼동 소마사랑"},
      "userStatus": "",
      "Replies": [
        {
          "id": 1,
          "content":
              "2021년 12월 하순에 실시된 DirectX 11 지원 업데이트 이후로 이 문제점들이 상당히 해소될 것으로 보인다.",
          "isDeleted": null,
          "createdAt": "2022-07-17T05:23:00.000Z",
          "updatedAt": "2022-07-17T05:23:00.000Z",
          "deletedAt": null,
          "fromThen": "17시간 전",
          "parentId": 1,
          "dealId": 1,
          "userId": 2,
          "User": {"nick": "역삼동 은이님"},
          "userStatus": "제안자",
        },
        {
          "id": 2,
          "content": "시간 엄수 바랍니다!",
          "isDeleted": null,
          "createdAt": "2022-07-17T05:23:17.000Z",
          "updatedAt": "2022-07-17T05:23:17.000Z",
          "deletedAt": null,
          "fromThen": "15시간 전",
          "parentId": 1,
          "dealId": 1,
          "userId": 2,
          "User": {"nick": "역삼동 은이님"},
          "userStatus": "제안자",
        },
        {
          "id": 3,
          "content": "그리고 1봉지에 몇 개 정도 들어있나요?",
          "isDeleted": null,
          "createdAt": "2022-07-17T05:23:23.000Z",
          "updatedAt": "2022-07-17T05:23:23.000Z",
          "deletedAt": null,
          "fromThen": "14시간 전",
          "parentId": 1,
          "dealId": 1,
          "userId": 3,
          "User": {"nick": "역삼동 kite"},
          "userStatus": "참여자",
        },
        {
          "id": 4,
          "content": "정확히는 모르겠는데, 7개 정도 들어있는 것 같아요!",
          "isDeleted": null,
          "createdAt": "2022-07-17T05:23:17.000Z",
          "updatedAt": "2022-07-17T05:23:17.000Z",
          "deletedAt": null,
          "fromThen": "12시간 전",
          "parentId": 1,
          "dealId": 1,
          "userId": 2,
          "User": {"nick": "역삼동 은이님"},
          "userStatus": "제안자",
        },
      ]
    },
    {
      "id": 1,
      "content": "5분 정도 늦을 것 같은데, 괜찮을까요?",
      "isDeleted": null,
      "createdAt": "2022-07-17T05:22:25.000Z",
      "updatedAt": "2022-07-17T05:22:25.000Z",
      "deletedAt": null,
      "fromThen": "12분 전",
      "dealId": 1,
      "userId": 4,
      "User": {"nick": "역삼동 kth"},
      "userStatus": "참여자",
      "Replies": [
        {
          "id": 0,
          "content": "넵! 기다리겠습니다!",
          "isDeleted": null,
          "createdAt": "2022-07-17T05:23:35.000Z",
          "updatedAt": "2022-07-17T05:23:35.000Z",
          "deletedAt": null,
          "fromThen": "11분 전",
          "parentId": 2,
          "dealId": 1,
          "userId": 2,
          "User": {"nick": "역삼동 은이님"},
          "userStatus": "제안자",
        }
      ]
    },
    {
      "id": 2,
      "content": "시간 조정 가능한가요?",
      "isDeleted": null,
      "createdAt": "2022-07-17T05:22:33.000Z",
      "updatedAt": "2022-07-17T05:22:33.000Z",
      "deletedAt": null,
      "fromThen": "7분 전",
      "dealId": 1,
      "userId": 1,
      "User": {"nick": "역삼동 소마짱짱"},
      "userStatus": "",
      "Replies": []
    }
  ];

  Future<List<Map<String, dynamic>>> loadComments() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return dataComments;
  }
}
