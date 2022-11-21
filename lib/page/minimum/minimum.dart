import 'package:chocobread/style/colorstyles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../utils/price_utils.dart';
import '../repository/minimum_repository.dart';



class MinimumList extends StatefulWidget {
  const MinimumList({super.key});
  

  @override
  State<MinimumList> createState() => _MinimumListState();

}

class _MinimumListState extends State<MinimumList> {
  String category1 = "";
  String category2 = "";
  String category3 = "";
  MinimumList minimumList = MinimumList();

  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      title: const Text("가격 비교"),
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        // Navigator 사용시 보통 자동으로 생성되나, 기타 처리 필요하므로 따로 생성
        onPressed: () {
          Navigator.pop(context);
        },
        icon: const Icon(
          Icons.arrow_back_ios_rounded,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _minimumChip() {
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        color: ColorStyle.fail,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
      child: const Text(
        "최저가",
        style: TextStyle(
            color: ColorStyle.failText,
            fontSize: 11,
            fontWeight: FontWeight.w700),
      ),
    );
  }

  Color titleColor(String mallName) {
    if (mallName == "N빵") {
      return ColorStyle.mainColor;
    }
    return Colors.black;
  }

  Color lmoneyColor(String mallName) {
    if (mallName == "N빵") {
      return ColorStyle.myRed;
    }
    return Colors.grey;
  }

  Widget _bodyWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          _category(),
          _line(),
          _minimumList(),
        ],
      ),
    );
  }

  getCategory() {
    category1 = dataMinimum[1]["category1"];
    category2 = dataMinimum[1]["category2"];
    category3 = dataMinimum[1]["category3"];
  }

  Widget _category() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: ColorStyle.ongoing,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
            child: Row(
              children: const [
                Text(
                  "택배비 포함 최저가순",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: ColorStyle.recruitcompleteText),
                ),
                SizedBox(
                  width: 5,
                ),
                FaIcon(
                  FontAwesomeIcons.chevronDown,
                  size: 12,
                  color: ColorStyle.recruitcompleteText,
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(category1),
              const SizedBox(
                width: 5,
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(category2),
              const SizedBox(
                width: 5,
              ),
              const FaIcon(
                FontAwesomeIcons.chevronRight,
                size: 12,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(category3),
            ],
          ),
        ],
      ),
    );
  }

  Widget _line() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
      width: double.infinity,
      height: 0.6,
      color: Colors.black.withOpacity(0.6),
    );
  }

  Widget _imageHolder(int index) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: ExtendedImage.network(dataMinimum[index]["image"].toString(),
          width: 90,
          height: 90,
          fit: BoxFit.fill,
          cache: true,
          enableLoadState: true,
          retries: 10,
          timeLimit: const Duration(seconds: 100),
          timeRetry: const Duration(seconds: 5)),
    );
  }

  Widget _rowItemOne(int index) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            dataMinimum[index]["mallName"],
            style: TextStyle(
                color: titleColor(dataMinimum[index]["mallName"]),
                fontWeight: (dataMinimum[index]["mallName"] == "N빵")
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: 18),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            dataMinimum[index]["title"],
            style: const TextStyle(color: Colors.grey),
          )
        ],
      ),
    );
  }

  Widget _rowItemTwo(int index) {
    return Expanded(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            (index == 0) ? _minimumChip() : const SizedBox.shrink(),
            const SizedBox(
              width: 7,
            ),
            Text(
              "${PriceUtils.calcStringToWonOnly(dataMinimum[index]["lprice"].toString())}원",
              style: TextStyle(
                color: lmoneyColor(dataMinimum[index]["mallName"]),
                fontWeight: (dataMinimum[index]["mallName"] == "N빵")
                    ? FontWeight.bold
                    : FontWeight.normal,
                fontSize: (dataMinimum[index]["mallName"] == "N빵") ? 16 : 14,
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 5,
        ),
        (dataMinimum[index]["mallName"] == "N빵")
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  FaIcon(
                    FontAwesomeIcons.box,
                    size: 11,
                    color: Colors.grey,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text(
                    "3,500원",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
        const SizedBox(
          height: 5,
        ),
        (dataMinimum[index]["mallName"] == "N빵")
            ? const SizedBox.shrink()
            : Text(
                "${PriceUtils.calcStringToWonOnly((dataMinimum[index]["lprice"] + 3500).toString())}원",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )
      ],
    ));
  }

  Widget _minimumList() {
    return ListView.separated(
        physics: const NeverScrollableScrollPhysics(), // 리스트뷰는 스크롤이 안되도록 처리하기
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _imageHolder(index),
                const SizedBox(
                  width: 20,
                ),
                _rowItemOne(index),
                _rowItemTwo(index),
              ],
            ),
          );
        },
        separatorBuilder: (BuildContext context, int index) {
          return Container(
            height: 1,
            color: const Color(0xfff0f0ef),
          );
        },
        itemCount: dataMinimum.length);
  }

  @override
  Widget build(BuildContext context) {
    getCategory();
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
