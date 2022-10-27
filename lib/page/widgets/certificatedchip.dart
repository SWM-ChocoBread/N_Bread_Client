import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../style/colorstyles.dart';

class CertificatedChip extends StatefulWidget {
  const CertificatedChip({super.key});

  @override
  State<CertificatedChip> createState() => _CertificatedChipState();
}

class _CertificatedChipState extends State<CertificatedChip> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        FaIcon(
          FontAwesomeIcons.medal,
          size: 12,
          color: Color(0xffFF6464),
        ),
        SizedBox(
          width: 5,
        ),
        Text(
          "인증",
          style: TextStyle(
              color: Color(0xffFF6464),
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
        SizedBox(
          width: 10,
        ),
      ],
    );
    // return const Padding(
    //   padding: EdgeInsets.only(right: 8.0),
    //   child: Chip(
    //     materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    //     avatar: FaIcon(
    //       FontAwesomeIcons.medal,
    //       size: 12,
    //       color: ColorStyle.mainColor,
    //     ),
    //     labelPadding: EdgeInsets.only(right: 5),
    //     label: Text(
    //       "인증",
    //       style: TextStyle(
    //           color: ColorStyle.mainColor,
    //           fontSize: 12,
    //           fontWeight: FontWeight.bold),
    //     ),
    //     // labelPadding: EdgeInsets.zero,
    //     backgroundColor: Colors.white,
    //     shape: RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(10))),
    //   ),
    // );
  }
}
