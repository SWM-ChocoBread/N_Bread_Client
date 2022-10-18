import 'package:chocobread/page/notionreview.dart';
import 'package:chocobread/page/openchatting.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class ServiceInfo extends StatefulWidget {
  ServiceInfo({Key? key}) : super(key: key);

  @override
  State<ServiceInfo> createState() => _ServiceInfoState();
}

class _ServiceInfoState extends State<ServiceInfo> {
  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.white,
    );
  }

  // Widget _notioninfo() {
  //   return const WebView(
  //     initialUrl:
  //         "https://freezing-bass-423.notion.site/ChocoBread-e11e8558cdc94676bfce4c279fe2774b",
  //     javascriptMode: JavascriptMode.unrestricted,
  //     gestureNavigationEnabled: true, // 스와이프로 이전 페이지로 돌아가는 기능 활성화
  //   );
  // }

  List introTextList = [
    {
      "subtitle": "N빵 서비스 소개",
      "bullets": [
        "이웃과 함께하는 구매를 통해 원하는 상품을 필요한 만큼 저렴한 가격에 가져갈 수 있는 플랫폼입니다.",
        "이웃과 함께 구매하고 싶은 물품이 있다면, 거래를 제안할 수 있어요.",
        "이웃과 함께 구매하고 싶은 물품이 N빵에 올라와 있다면, 거래에 참여할 수 있어요.",
      ]
    },
    {
      "subtitle": "이런 경우, 저희 서비스가 유용해요!",
      "bullets": [
        "배송비를 아끼고 싶은 경우",
        "상품이 배송비보다 싼 경우",
        "해외직구 배송비를 이웃과 나누고 싶은 경우",
        "대용량 제품을 원하는 만큼만 가져가고 싶은 경우",
      ]
    },
    {
      "subtitle": "이웃과 함께 구매라고 싶은 게 생겼어요!",
      "bullets": [
        "거래하고 싶은 상품의 이름, 해당 상품의 가격, 나를 포함해서 거래에 참여할 사람의 수, 거래하고 싶은 날짜와 시간, 장소를 정해서 거래를 제안할 수 있어요.",
        "추가적으로 상품 사진과 상품 판매 링크를 추가할 수 있어요.",
      ]
    },
    {
      "subtitle": "N빵에 올라와 있는 물품을 구매하고 싶어요!",
      "bullets": [
        "N빵에 올라와 있는 상품 구매에 참여할 수 있어요!",
      ]
    }
  ];

  // Widget _bodyWidget() {
  //   return FutureBuilder(
  //       future: rootBundle.loadString("assets/markdown/notioninfo.md"),
  //       builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
  //         if (snapshot.hasData) {
  //           return Markdown(data: snapshot.data!);
  //         }
  //         return const Center(
  //           child: CircularProgressIndicator(),
  //         );
  //       });
  // }

  Widget _title() {
    return const Text(
      "N빵",
      style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
    );
  }

  Widget _subTitle(String content) {
    return Text(
      content,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }

  Widget _bullets(List bulletsList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: bulletsList.map((map) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '\u2022',
              softWrap: true,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            Expanded(
                child: Text(
              map,
              style: const TextStyle(height: 1.5),
            )),
          ],
        );
      }).toList(),
    );
  }

  Widget _introBox(Map data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _subTitle(data["subtitle"]),
        const SizedBox(
          height: 10,
        ),
        _bullets(data["bullets"]),
        const SizedBox(
          height: 40,
        ),
      ],
    );
  }

  Widget _bodyWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                _title(),
                const SizedBox(
                  height: 25,
                )
              ] +
              introTextList.map((map) {
                return _introBox(map);
              }).toList(),
        ),
      ),
    );
  }

  Widget _speeddial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: ColorStyle.mainColor,
      elevation: 3,
      overlayOpacity: 0.3,
      overlayColor: Colors.black,
      closeManually: false,
      childPadding: const EdgeInsets.only(bottom: 10),
      children: [
        SpeedDialChild(
            foregroundColor: Colors.white,
            backgroundColor: ColorStyle.lightMainColor,
            child: const Icon(Icons.border_color_rounded), // edit_note_rounded
            onTap: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return NotionReview();
              }));
            }),
        SpeedDialChild(
          foregroundColor: Colors.white,
          backgroundColor: ColorStyle.darkMainColor,
          child: const FaIcon(FontAwesomeIcons
              .solidCommentDots), // chat_rounded, question_answer_rounded
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (BuildContext context) {
              return const OpenChatting();
            }));
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // extendBodyBehindAppBar: true,
      appBar: _appBarWidget(),
      body: _bodyWidget(),
      // _notioninfo(),
      // floatingActionButton: _speeddial(),
    );
  }
}
