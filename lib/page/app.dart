import 'package:chocobread/page/mypage.dart';
import 'package:chocobread/page/openchatting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'home.dart';
import 'package:chocobread/constants/sizes_helper.dart';
import 'mypage.dart';

class App extends StatefulWidget {
  static String routeName = "/page";

  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late int _currentPageIndex;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentPageIndex = 1;
  }

  // PreferredSizeWidget _appbarWidget() {
  //   return AppBar(
  //     leading: IconButton(
  //         onPressed: () {},
  //         icon: SvgPicture.asset(
  //           "assets/svg/logo.svg",
  //           width: 100,
  //         )), // logo, hamburger,
  //     title: GestureDetector(
  //       onTap: () {
  //         print("click");
  //       },
  //       child: Row(
  //         children: [
  //           Text('역삼동'),
  //           Icon(Icons.arrow_drop_down_rounded),
  //         ],
  //       ),
  //     ), // name of the app
  //     elevation: 0,
  //     actions: [
  //       // IconButton(onPressed: () {}, icon: Icon(Icons.search)),
  //       // IconButton(onPressed: () {}, icon: Icon(Icons.tune)),
  //       IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle)),
  //       IconButton(
  //           onPressed: () {}, icon: const Icon(Icons.arrow_back_rounded)),
  //       IconButton(
  //           onPressed: () {}, icon: const Icon(Icons.border_color_rounded)),
  //     ], // buttons at the end
  //   );
  // }

  Widget _bodyWidget() {
    switch (_currentPageIndex) {
      case 0:
        return const OpenChatting();
      case 1:
        return const Home();
      case 2:
        return MyPage();
    }
    return Container();
  }

  // BottomNavigationBarItem _bottomNavigationBarItem(String iconName, String label) {
  //   return BottomNavigationBarItem(icon: Icon(Icons.'${iconName}'), label: label)
  // }

  Widget _bottomNavigationBarWidget() {
    return BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          print(index);
          setState(() {
            _currentPageIndex = index;
          });
        },
        elevation: 0,
        currentIndex: _currentPageIndex,
        selectedFontSize: 12,
        selectedItemColor: Colors.black,
        selectedLabelStyle: const TextStyle(color: Colors.black),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // icon: SvgPicture.asset("assets/svg/")
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.headphones_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.headphones),
            ),
            label: "고객센터",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.home_outlined),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.home),
            ),
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.person_outline),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(Icons.person),
            ),
            label: "마이 페이지",
          )
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        // appBar: _appbarWidget(),
        body: _bodyWidget(),
        bottomNavigationBar: _bottomNavigationBarWidget(),
        // bottomNavigationBar: BottomNavigationBar(
        //   items: [
        //     BottomNavigationBarItem(
        //       icon: Icon(Icons.home_outlined),
        //       activeIcon: Icon(Icons.home),
        //       label: 'home',
        //     ),
        //   ],
        // ),
      ),
      onWillPop: () async {
        return false;
      },
    );
  }
}
