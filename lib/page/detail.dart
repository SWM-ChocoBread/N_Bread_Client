import 'package:carousel_slider/carousel_slider.dart';
import 'package:chocobread/page/check.dart';
import 'package:chocobread/page/checkparticipation.dart';
import 'package:flutter/material.dart';

import '../utils/price_utils.dart';
import 'done.dart';

class DetailContentView extends StatefulWidget {
  Map<String, dynamic> data;
  DetailContentView({Key? key, required this.data}) : super(key: key);

  @override
  State<DetailContentView> createState() => _DetailContentViewState();
}

class _DetailContentViewState extends State<DetailContentView> {
  late Size size;
  late List<Map<String, String>> imgList; // imgList 선언
  late int _current; // _current 변수 선언
  double scrollPositionToAlpha = 0;
  ScrollController _scrollControllerForAppBar = ScrollController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _scrollControllerForAppBar.addListener(() {
      print(_scrollControllerForAppBar.offset);
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    size = MediaQuery.of(context).size; // 해당 기기의 가로 사이즈로 초기화
    _current = 0; // _current 인덱스를 0으로 초기화
    imgList = [
      // imgList 에 들어갈 이미지들 나열
      {"id": "0", "url": widget.data["image"].toString()},
      {"id": "1", "url": widget.data["image"].toString()},
      {"id": "2", "url": widget.data["image"].toString()},
    ];
  }

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      backgroundColor: Colors.transparent, // 투명 처리
      flexibleSpace: Container(
        // appbar에 그래디언트 추가해서 아이콘 명확하게 보이도록 처리
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
              Colors.black.withOpacity(0.4),
              Colors.black.withOpacity(0.003)
            ])),
      ),
      elevation: 0,
      leading: IconButton(
        // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.white,
        ),
      ),
      actions: [
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.share,
              color: Colors.white,
            )),
        IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.more_vert,
              color: Colors.white,
            )),
      ],
    );
  }

  Widget _makeSliderImage() {
    return Container(
      child: Stack(
        // 이미지와 indicator가 겹치게 만들어야 하므로
        children: [
          Hero(
            // 사진 확대되는 애니메이션
            tag: widget.data["cid"].toString(),
            child: CarouselSlider(
              items: imgList.map((map) {
                return Image.asset(
                  map["url"].toString(),
                  width: size.width,
                  fit: BoxFit.fill,
                );
              }).toList(),
              // carouselController: _controller,
              options: CarouselOptions(
                  height: size.width,
                  initialPage: 0, //첫번째 페이지
                  enableInfiniteScroll: false, // 무한 스크롤 방지
                  viewportFraction: 1, // 전체 화면 사용
                  onPageChanged: (index, reason) {
                    setState(() {
                      _current = index;
                    });
                    print(index);
                  }),
              // Image.asset(
              //   widget.data["image"].toString(),
              //   width: size.width,
              //   fit: BoxFit.fill,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: imgList.map((map) {
                // List.generate(imgList.length, (index) {
                // imgList.asMap().entries.map((entry) {
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

  Widget _sellerSimpleInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
      child: Row(
        children: [
          IconButton(
              onPressed: () {},
              icon: const Icon(
                Icons.circle,
                color: Color(0xffF6BD60),
                // size: 30,
              )),
          const SizedBox(
            width: 7,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.data["sellerNickname"].toString(),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                widget.data["sellerAddress"].toString(),
                style: const TextStyle(fontSize: 13),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
        // margin: const EdgeInsets.symmetric(horizontal: 15),
        height: 10,
        // color: Colors.grey.withOpacity(0.3),
        color: const Color(0xfff0f0ef));
  }

  Widget _contentsTitle() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // stretch를 써야 전체 화면을 활용하면서 왼쪽으로 정렬되는 효과
        children: [
          const SizedBox(
            height: 20,
          ),
          Text(
            widget.data["title"].toString(),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          Text(
            widget.data["written"].toString(),
            style: const TextStyle(fontSize: 12),
          ),
          const SizedBox(
            height: 15,
          ),
        ],
      ),
    );
  }

  Widget _contentsDetail() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.data["contents"].toString(),
            style:
                const TextStyle(fontSize: 15, height: 1.5), // height 는 줄간격 사이
          ),
          const SizedBox(
            height: 40,
          ),
        ],
      ),
    );
  }

  Widget _commentTitle() {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: const Text(
          "댓글",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ));
  }

  Widget _bodyWidget() {
    return CustomScrollView(
      // list 를 그리드뷰로 처리할 때는 CustomScrollView로 처리한다.
      // SingleChildScrollView : scroll 가능하게 만들기, 한 화면에 안 들어가면 생기는 에러 해결
      controller: _scrollControllerForAppBar,
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _makeSliderImage(),
              _sellerSimpleInfo(),
              _line(),
              _contentsTitle(),
            ],
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // 한 줄에 몇 개의 아이템
                mainAxisSpacing: 10, // 가로 간격 생김
                crossAxisSpacing: 10, // 세로 간격 생김
                childAspectRatio:
                    8), // childAspectRatio 는 grid의 높이를 조절하기 위한 것, 클수록 높이 줄어든다.
            delegate: SliverChildListDelegate([
              const Text("판매 링크"),
              Container(
                width: 300,
                color: Colors.red,
                child: Text(
                  widget.data["link"].toString(),
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      backgroundColor: Color.fromARGB(255, 254, 184, 207)),
                ),
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text("단위 가격"),
                    const SizedBox(
                      width: 7,
                    ),
                    IconButton(
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        iconSize: 17,
                        icon: const Icon(
                          Icons.help_outline,
                        )),
                  ]),
              Text(
                PriceUtils.calcStringToWon(widget.data["price"].toString()),
              ),
              const Text("모집 인원"),
              Text('${widget.data["current"]}/${widget.data["total"]}'),
              const Text("모집 마감 일자"),
              Text(widget.data["date"].toString()), // TODO : 수정 필요함
              const Text("거래 일시"),
              Text(widget.data["date"].toString()),
              const Text("거래 장소"),
              Text(
                widget.data["place"].toString(),
                overflow: TextOverflow.ellipsis,
              ),
            ]
                //   List.generate(12, (index) {
                //   return Container(
                //     height: 1,
                //     color: Colors.red,
                //   );
                // }).toList()
                ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate(
            [
              _contentsDetail(),
              _line(),
              _commentTitle(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bottomNavigationBarWidget() {
    return Container(
      width: size.width,
      height: 55,
      color: Colors.lightBlue.withOpacity(0.2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(), // 수량 + - 정하기 버튼
          Container(), // 총 가격 창
          Expanded(
              child: Row(
            children: [
              TextButton(
                // padding:
                //     const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.circular(20),
                //   color: const Color(
                //       0xffF28482), // decoration을 쓰면 color가 decoration 안으로 들어가야 한다.
                // ),
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CheckParticipation(
                          data: widget.data,
                        );
                      });
                },

                style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                    shape: const StadiumBorder(),
                    // backgroundColor: const Color(0xffF28482)),
                    backgroundColor: const Color(0xffF6BD60)),
                child: const Text(
                  "참여하기",
                  style: TextStyle(
                      color: Color(0xff323232),
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // 앱 바 위에까지 침범 허용
      appBar: _appbarWidget(),
      body: _bodyWidget(),
      bottomNavigationBar: _bottomNavigationBarWidget(),
    );
  }
}
