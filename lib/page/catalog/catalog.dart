import 'package:chocobread/page/catalog/catalog_webview.dart';
import 'package:chocobread/page/repository/catalog_repository.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/mychip.dart';

class Catalog extends StatefulWidget {
  const Catalog({super.key});

  @override
  State<Catalog> createState() => _CatalogState();
}

class _CatalogState extends State<Catalog> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      elevation: 0,
      bottomOpacity: 0,
      backgroundColor: Colors.transparent,
      title: const Text("N빵 추천 상품"),
      centerTitle: false,
      titleSpacing: 23,
    );
  }

  Widget RankChip(String content, Color textcolor, Color bgcolor) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 7),
          decoration: BoxDecoration(
              color: bgcolor,
              borderRadius: const BorderRadius.all(Radius.circular(10))),
          child: Row(
            children: [
              FaIcon(
                FontAwesomeIcons.medal,
                size: 12,
                color: textcolor,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                content,
                style: TextStyle(
                    color: textcolor,
                    fontSize: 13,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget WhichChip(int index) {
    if (index == 0) {
      return RankChip(
        "1위",
        ColorStyle.sellerText,
        ColorStyle.seller,
      );
    } else if (index == 1) {
      return RankChip(
        "2위",
        Color.fromARGB(255, 253, 169, 91),
        Color.fromARGB(255, 253, 240, 227),
      );
    } else if (index == 2) {
      return RankChip(
        "3위",
        ColorStyle.myYellow,
        Color.fromARGB(255, 254, 244, 213),
      );
    } else if (index == 3) {
      return RankChip(
        "4위",
        ColorStyle.participantText,
        ColorStyle.participant,
      );
    } else if (index == 4) {
      return RankChip(
        "5위",
        ColorStyle.failText,
        ColorStyle.fail,
      );
    }
    //
    return const SizedBox.shrink();
  }

  Widget _imageHolder(int index, String imageLink) {
    return Stack(children: [
      ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(10)),
        child: ExtendedImage.network(imageLink.toString(),
            width: double.infinity,
            height: 120,
            fit: BoxFit.cover,
            cache: true,
            enableLoadState: true,
            retries: 10,
            timeLimit: const Duration(seconds: 100),
            timeRetry: const Duration(seconds: 5)),
      ),
      WhichChip(index),
    ]);
  }

  Widget _catalogGrid(List catalogItems) {
    return GridView.builder(
      itemCount: catalogItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 40, // 수직 기준 자식 위젯간의 간격
        crossAxisSpacing: 0,
      ),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () async {
            if (catalogItems[index]["link"] == null) {
              return null;
            }
            if (await canLaunchUrl(Uri.parse(catalogItems[index]["link"]))) {
              // await launchUrl(
              //   Uri.parse(catalogItems[index]["link"]),
              //   // mode: LaunchMode.externalApplication
              // );
              Get.to(() => CatalogWebview(url: catalogItems[index]["link"]));
            }
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Column(
              children: [
                _imageHolder(index, catalogItems[index]["image_link"]),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                        child: Text(
                      catalogItems[index]["name"],
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ))
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    (catalogItems[index]["discount_percent"] == null)
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(
                              catalogItems[index]["discount_percent"],
                              style: const TextStyle(
                                color: ColorStyle.certificated,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                    Text(
                      "${catalogItems[index]["price"]}원",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      catalogItems[index]["unit_price"],
                      style: const TextStyle(fontSize: 13),
                    )
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _bodyWidget() {
    return FutureBuilder(
        future: loadCatalog(),
        builder: (context, snapshot) {
          print("snapshot.data : ${snapshot.data}");
          if (snapshot.hasData) {
            print("snapshot.data : ${snapshot.data}");
            return _catalogGrid(snapshot.data as List<dynamic>);
          }
          return const Center(child: CircularProgressIndicator());
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
