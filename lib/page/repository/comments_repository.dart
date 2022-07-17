class CommentsRepository {
  var dataComments = {
    "code": 200,
    "message": "get comments",
    "isSuccess": true,
    "result": [
      {
        "id": 1,
        "content":
            "정식 오픈 기준 시점으로 최적화는 준수한 편으로, 권장 사양을 지킨다면 원활하게 플레이 가능하다. 2011년 이후에 나온 쿼드코어 이상의 CPU와 16기가 정도의 램을 갖춘 컴퓨터로도 대규모 전투를 연출한 상황에서 프레임이 조금 떨어지는 수준이다. 다만, QHD 이상 해상도에서 공식 요구사항이 극단적으로 높아지는 것을 볼수 있는데, 60프레임 완전 보장을 기준으로 설명된 것으로 추정된다. 실제 플레이 상황에선 FHD 해상도와, 모든 옵션 최상을 기준으로 6세대 이후의 인텔 CPU, 라이젠 이후의 AMD CPU와 GTX1060 정도의 사양으로도 원활한 플레이가 가능하다.",
        "isDeleted": null,
        "createdAt": "2022-07-17T05:22:12.000Z",
        "updatedAt": "2022-07-17T05:22:12.000Z",
        "deletedAt": null,
        "dealId": 1,
        "userId": 1,
        "Replies": [
          {
            "id": 1,
            "content":
                "2021년 12월 하순에 실시된 DirectX 11 지원 업데이트 이후로 이 문제점들이 상당히 해소될 것으로 보인다.",
            "isDeleted": null,
            "createdAt": "2022-07-17T05:23:00.000Z",
            "updatedAt": "2022-07-17T05:23:00.000Z",
            "deletedAt": null,
            "parentId": 1,
            "dealId": 1,
            "userId": 1
          },
          {
            "id": 2,
            "content": "22222222222222222222222",
            "isDeleted": null,
            "createdAt": "2022-07-17T05:23:17.000Z",
            "updatedAt": "2022-07-17T05:23:17.000Z",
            "deletedAt": null,
            "parentId": 1,
            "dealId": 1,
            "userId": 1
          },
          {
            "id": 3,
            "content": "333333333333333333333333333333333333",
            "isDeleted": null,
            "createdAt": "2022-07-17T05:23:23.000Z",
            "updatedAt": "2022-07-17T05:23:23.000Z",
            "deletedAt": null,
            "parentId": 1,
            "dealId": 1,
            "userId": 1
          }
        ]
      },
      {
        "id": 2,
        "content": "ㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎㅎ",
        "isDeleted": null,
        "createdAt": "2022-07-17T05:22:25.000Z",
        "updatedAt": "2022-07-17T05:22:25.000Z",
        "deletedAt": null,
        "dealId": 1,
        "userId": 1,
        "Replies": [
          {
            "id": 4,
            "content": "333333333333333333333333333333333333",
            "isDeleted": null,
            "createdAt": "2022-07-17T05:23:26.000Z",
            "updatedAt": "2022-07-17T05:23:26.000Z",
            "deletedAt": null,
            "parentId": 2,
            "dealId": 1,
            "userId": 1
          },
          {
            "id": 5,
            "content": "메이플스토리",
            "isDeleted": null,
            "createdAt": "2022-07-17T05:23:35.000Z",
            "updatedAt": "2022-07-17T05:23:35.000Z",
            "deletedAt": null,
            "parentId": 2,
            "dealId": 1,
            "userId": 1
          }
        ]
      },
      {
        "id": 3,
        "content": "ㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴㄴ",
        "isDeleted": null,
        "createdAt": "2022-07-17T05:22:33.000Z",
        "updatedAt": "2022-07-17T05:22:33.000Z",
        "deletedAt": null,
        "dealId": 1,
        "userId": 1,
        "Replies": []
      }
    ]
  };

  Future loadComments() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return dataComments;
  }
}
