import 'package:carousel_slider/carousel_slider.dart';
import 'package:chocobread/constants/sizes_helper.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../repository/event_banner_repository.dart';

class EventBanner extends StatefulWidget {
  EventBanner({Key? key}) : super(key: key);

  @override
  State<EventBanner> createState() => _EventBannerState();
}

class _EventBannerState extends State<EventBanner> {
  late List eventBannerImages;

  @override
  void initState() {
    super.initState();
    eventBannerImages = [];
  }

  @override
  void didChangeDependencies() async {
    super.didChangeDependencies();
    // eventBannerImages = await loadEventBanner(); // 나중에 주석 해제해서 사용할 것!
  }

  // detail.dart 의 _itemsForSliderImage 참고
  List<Widget> _itemsForEventBanner() {
    // 이벤트 배너 이미지가 있는 경우 : 이미지 배너를 보여준다.
    return eventBannerImages.map((map) {
      return ExtendedImage.network(map["dealImage"].toString());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        autoPlay: true,
        height: 100,
        initialPage: 0, //첫번째 페이지
        enableInfiniteScroll: true, // 무한 스크롤 가능하게 하기
        viewportFraction: 1, // 전체 화면 사용
      ),
      items:
          // (eventBannerImages.length != 0)
          //     ? _itemsForEventBanner()
          //     : List.empty(),
          [
        Container(color: ColorStyle.darkMainColor),
        Container(
          color: ColorStyle.lightMainColor,
        ),
        Container(
          color: ColorStyle.mainColor,
        )
      ],
    );
  }
}
