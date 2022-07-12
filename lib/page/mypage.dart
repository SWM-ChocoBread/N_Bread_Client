import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/nicknamechange.dart';
import 'package:chocobread/page/repository/ongoing_repository.dart';
import 'package:flutter/material.dart';

class MyPage extends StatefulWidget {
  MyPage({Key? key}) : super(key: key);

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late OngoingRepository ongoingRepository;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    ongoingRepository = OngoingRepository();
  }

  PreferredSizeWidget _appBarWidget() {
    return AppBar(
      title: const Text(
        "My Page",
      ),
      centerTitle: false,
      titleSpacing: 23,
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      automaticallyImplyLeading: false, // 자동으로 생성되는 뒤로가기 버튼 제거하기
    );
  }

  Widget _nickname() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
          const Text(
            // user nickname 이 들어와야 하는 공간
            "역삼동 은이님",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(
            width: 15,
          ),
          IconButton(
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (BuildContext context) {
                  return NicknameChange();
                }));
              }, // 닉네임 변경 화면으로 전환
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              iconSize: 15,
              icon: const Icon(
                Icons.arrow_forward_ios_rounded,
              )),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(height: 10, color: const Color(0xfff0f0ef));
  }

  Widget _ongoingTitle() {
    return Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        child: const Text(
          "진행 중인 거래",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ));
  }

  _loadOngoing() {
    return ongoingRepository.loadOngoing();
  }

  _makeOngoingList(List<Map<String, String>> dataOngoing) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      itemBuilder: (BuildContext context, int index) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          child: Row(
            children: [Text(dataOngoing[index]["price"].toString())],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Container(
          height: 10,
          color: const Color(0xfff0f0ef),
        );
      },
      itemCount: dataOngoing.length,
    );
  }

  Widget _bodyWidget() {
    // return FutureBuilder(builder: (){})

    return Container(
      // margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          _nickname(),
          _line(),
          _ongoingTitle(),
          // _makeOngoingList(dataOngoing),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBarWidget(),
      body: _bodyWidget(),
    );
  }
}
