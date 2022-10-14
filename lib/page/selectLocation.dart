import 'package:flutter/material.dart';

import '../style/colorstyles.dart';

class MainPage extends StatefulWidget {
  SelectLocation createState() => SelectLocation();
}

String selectedgu = "서초구";
List<DropdownMenuItem<String>> get dropdownItems {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("강남구"), value: "강남구"),
    DropdownMenuItem(child: Text("서초구"), value: "서초구"),
    DropdownMenuItem(child: Text("광진구"), value: "광진구"),
    DropdownMenuItem(child: Text("관악구"), value: "관악구"),
  ];
  return menuItems;
}

List<DropdownMenuItem<String>> get dropdownItem2 {
  List<DropdownMenuItem<String>> menuItems = [];
  if (selectedValue == "서초구") {
    return seocho;
  } else if (selectedValue == "광진구") {
    return guangjin;
  } else if (selectedValue == "관악구") {
    return guanak;
  } else if (selectedValue == "강남구") {
    return gangnam;
  }
  return menuItems;
}

List<DropdownMenuItem<String>> get gangnam {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("압구정동"), value: "압구정동"),
    DropdownMenuItem(child: Text("신사동"), value: "신사동"),
    DropdownMenuItem(child: Text("청담동"), value: "청담동"),
    DropdownMenuItem(child: Text("논현동"), value: "논현동"),
    DropdownMenuItem(child: Text("삼성동"), value: "삼성동"),
    DropdownMenuItem(child: Text("역삼동"), value: "역삼동"),
    DropdownMenuItem(child: Text("대치동"), value: "대치동"),
    DropdownMenuItem(child: Text("도곡동"), value: "도곡동"),
    DropdownMenuItem(child: Text("일원동"), value: "일원동"),
    DropdownMenuItem(child: Text("수서동"), value: "수서동"),
    DropdownMenuItem(child: Text("논현동"), value: "논현동"),
    DropdownMenuItem(child: Text("자곡동"), value: "자곡동"),
    DropdownMenuItem(child: Text("율현동"), value: "율현동"),
    DropdownMenuItem(child: Text("세곡동"), value: "세곡동"),
  ];
  return menuItems;
}

List<DropdownMenuItem<String>> get seocho {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("서초동"), value: "서초동"),
    DropdownMenuItem(child: Text("반포동"), value: "반포동"),
    DropdownMenuItem(child: Text("방배동"), value: "방배동"),
    DropdownMenuItem(child: Text("잠원동"), value: "잠원동"),
    DropdownMenuItem(child: Text("내곡동"), value: "내곡동"),
    DropdownMenuItem(child: Text("양재동"), value: "양재동"),
    DropdownMenuItem(child: Text("우면동"), value: "우면동"),
    DropdownMenuItem(child: Text("신원동"), value: "신원동"),
    DropdownMenuItem(child: Text("염곡동"), value: "염곡동"),
    DropdownMenuItem(child: Text("원지동"), value: "원지동"),
  ];
  return menuItems;
}

List<DropdownMenuItem<String>> get guanak {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("남현동"), value: "남현동"),
    DropdownMenuItem(child: Text("봉천동"), value: "봉천동"),
    DropdownMenuItem(child: Text("신림동"), value: "신림동"),
  ];
  return menuItems;
}

List<DropdownMenuItem<String>> get guangjin {
  List<DropdownMenuItem<String>> menuItems = [
    DropdownMenuItem(child: Text("중곡동"), value: "중곡동"),
    DropdownMenuItem(child: Text("군자동"), value: "군자동"),
    DropdownMenuItem(child: Text("능동"), value: "능동"),
    DropdownMenuItem(child: Text("화양동"), value: "화양동"),
    DropdownMenuItem(child: Text("자양동"), value: "자양동"),
    DropdownMenuItem(child: Text("구의동"), value: "구의동"),
    DropdownMenuItem(child: Text("광장동"), value: "광장동"),
  ];
  return menuItems;
}

String selectedValue = "";
String selectedValue2 = "";

class SelectLocation extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        //ackgroundColor: Colors.amber[800],
        appBar: AppBar(
          //title: Text(''),
          //backgroundColor: Colors.amber[700],
          centerTitle: true,
          elevation: 0.0,
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(30.0, 0, 30.0, 0.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: <
                  Widget>[
            Text(
              '내 동네 설정하기',
              style: TextStyle(
                  color: Colors.black,
                  //letterSpacing: 2.0,
                  fontSize: 28.0,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text(
              'N빵은 서울 일부 지역에서 사용가능해요.',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
                //letterSpacing: 2.0,
              ),
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                    width: 150.0,
                    child: DecoratedBox(
                        decoration: ShapeDecoration(
                          //color: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 0.1,
                                style: BorderStyle.solid,
                                color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),

                        //width: 1,
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                                hint: Container(
                                  //width: 150, //and here
                                  child: (selectedValue == "")
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                          ),
                                          child: Text(
                                            "자치구",
                                            style:
                                                TextStyle(color: Colors.grey),
                                            textAlign: TextAlign.start,
                                          ))
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                          ), //apply padding to some sides only
                                          child: Text(
                                            selectedValue,
                                            style:
                                                TextStyle(color: Colors.black),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),
                                ),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    selectedValue = newValue!;
                                  });
                                },
                                items: dropdownItems)))),
                SizedBox(
                    width: 150.0,
                    child: DecoratedBox(
                        decoration: ShapeDecoration(
                          //color: Colors.cyan,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 0.1,
                                style: BorderStyle.solid,
                                color: Colors.grey),
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                        ),

                        //width: 1,
                        child: DropdownButtonHideUnderline(
                            child: DropdownButton(
                                hint: Container(
                                  //width: 150, //and here
                                  child: (selectedValue2 == "")
                                      ? Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                          ),
                                          child: Text(
                                            "법정동",
                                            style:
                                                TextStyle(color: Colors.grey),
                                            textAlign: TextAlign.end,
                                          ))
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            left: 15,
                                          ),
                                          child: Text(
                                            selectedValue2,
                                            style:
                                                TextStyle(color: Colors.black),
                                            textAlign: TextAlign.end,
                                          )),
                                ),
                                onChanged: (String? newValue) {
                                  if (selectedValue != "") {
                                    print("${selectedValue != ""}");
                                    setState(() {
                                      selectedValue2 = newValue!;
                                      print(
                                          "${selectedValue} ${selectedValue2}이 선택되었습니다. API를 호출해주세요");
                                    });
                                  } else {
                                    //스낵바 호출
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBarSelectDong);
                                    null;
                                  }
                                },
                                items: dropdownItem2)))),
              ],
            )
          ]),
        ));
  }

  static const snackBarSelectDong = SnackBar(
    content: Text(
      "자치구 선택 후 법정동 선택이 가능합니다!",
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: ColorStyle.darkMainColor,
    duration: Duration(milliseconds: 2000),
    behavior: SnackBarBehavior.floating,
    elevation: 3,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
      Radius.circular(5),
    )),
  );
}
