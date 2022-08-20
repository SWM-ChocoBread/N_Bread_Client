import 'package:chocobread/page/customerservice.dart';
import 'package:chocobread/page/mypage.dart';
import 'package:chocobread/page/openchatting.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';
import 'package:chocobread/constants/sizes_helper.dart';
import 'mypage.dart';
import 'notioninfo.dart';
import 'package:jwt_decode/jwt_decode.dart';

class App extends StatefulWidget {
  static String routeName = "/page";

  const App({Key? key}) : super(key: key);

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  late int _currentPageIndex;
  PageController _pageController = PageController(initialPage: 1);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _currentPageIndex = 1; // 처음 페이지는 항상 홈 화면으로 설정
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
    return PageView(
      controller: _pageController,
      onPageChanged: (newPageIndex) {
        setState(() {
          _currentPageIndex = newPageIndex;
        });
      },
      children: [CustomerService(), const Home(), MyPage()],
    );
    //   switch (_currentPageIndex) {
    //     case 0:
    //       return NotionInfo();
    //     case 1:
    //       return const Home();
    //     case 2:
    //       return MyPage();
    //   }
    //   return Container();
  }

  Widget _bottomNavigationBarWidget() {
    return BottomNavigationBar(
        // type: BottomNavigationBarType.fixed,
        onTap: (int index) {
          _pageController.animateToPage(index,
              duration: const Duration(milliseconds: 500), curve: Curves.ease);
        },
        elevation: 0,
        backgroundColor: Colors.transparent,
        currentIndex: _currentPageIndex,
        selectedFontSize: 12,
        selectedItemColor: ColorStyle.mainColor,
        selectedLabelStyle: const TextStyle(color: ColorStyle.mainColor),
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            // icon: SvgPicture.asset("assets/svg/")
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(
                Icons.headset_rounded,
                size: 22,
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: Icon(
                Icons.headset_rounded,
                size: 24,
              ),
            ),
            label: "고객센터",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: FaIcon(
                FontAwesomeIcons.house,
                size: 18,
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: FaIcon(
                FontAwesomeIcons.house,
                size: 20,
              ),
            ),
            label: "홈",
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: FaIcon(
                FontAwesomeIcons.solidUser,
                size: 18,
              ),
            ),
            activeIcon: Padding(
              padding: EdgeInsets.only(bottom: 3),
              child: FaIcon(
                FontAwesomeIcons.solidUser,
                size: 20,
              ),
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
