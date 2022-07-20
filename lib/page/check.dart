import 'package:chocobread/constants/sizes_helper.dart';
import 'package:flutter/material.dart';

import '../utils/price_utils.dart';

class CheckParticipationTest extends StatefulWidget {
  Map<String, dynamic> data;
  CheckParticipationTest({Key? key, required this.data}) : super(key: key);

  @override
  State<CheckParticipationTest> createState() => _CheckParticipationState();
}

class _CheckParticipationState extends State<CheckParticipationTest> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        // width: 5,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.report_problem_outlined,
                  color: Colors.red,
                ),
                SizedBox(
                  width: 12,
                ),
                Text(
                  "주의",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                )
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("'참여하기'를 누르면, 거래 취소는 불가합니다."),
                  Text("신중하게 결정해주세요!"),
                  Text("거래에 참여하시겠습니까?"),
                ],
              ),
            ),
            Text(
              "${widget.data["title"]}",
              style: const TextStyle(fontWeight: FontWeight.bold),
              softWrap: true,
            ),
            SizedBox(
              child: GridView.extent(
                maxCrossAxisExtent: 6,
                children: [
                  const Text("가격"),
                  Text(PriceUtils.calcStringToWon(
                      widget.data["personalPrice"].toString()))
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
