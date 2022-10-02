import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DetailImageView extends StatefulWidget {
  List<Map<String, String>> imgList;
  int currentIndex;
  DetailImageView({Key? key, required this.imgList, required this.currentIndex})
      : super(key: key);

  @override
  State<DetailImageView> createState() => _DetailImageViewState();
}

class _DetailImageViewState extends State<DetailImageView> {
  late int _current; // _current 변수 선언

  @override
  void initState() {
    super.initState();
    _current = widget.currentIndex; // _current 인덱스를 0으로 초기화
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _current = widget.currentIndex; // _current 인덱스를 0으로 초기화
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      leading: IconButton(
          // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const FaIcon(
            FontAwesomeIcons.x,
            color: Colors.white,
            size: 20,
          )),
      centerTitle: false,
      titleSpacing: 0,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: true,
    );
  }

  List<Widget> _itemsForSliderImage() {
    return widget.imgList.map((map) {
      return ExtendedImage.network(
        map["_url"].toString(),
        cache: true,
        enableLoadState: true,
        width: double.infinity,
        fit: BoxFit.fitWidth,
      );
    }).toList();
  }

  Widget _bodyWidget() {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: CarouselSlider(
              items: _itemsForSliderImage(),
              options: CarouselOptions(
                  height: double.infinity,
                  initialPage: widget.currentIndex, // 첫번째 페이지는 detail에서 유저가 클릭해서 들어온 페이지
                  enableInfiniteScroll: false, // 무한 스크롤 방지
                  viewportFraction: 1, // 전체 화면 사용
                  onPageChanged: (firstIndex, reason) {
                    setState(() {
                      _current = firstIndex;
                    });
                    print(firstIndex);
                  }),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: widget.imgList.map((map) {
                return Container(
                  width: 10.0,
                  height: 10.0,
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 4.0),
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _current == int.parse(map["id"].toString())
                          // (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.white.withOpacity(0.4)),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
