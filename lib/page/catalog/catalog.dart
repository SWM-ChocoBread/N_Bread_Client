import 'package:chocobread/page/catalog/catalog_webview.dart';
import 'package:chocobread/page/repository/catalog_repository.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Widget _imageHolder(int index) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(10)),
      child: ExtendedImage.network(catalogItems[index]["image_link"].toString(),
          height: 120,
          fit: BoxFit.cover,
          cache: true,
          enableLoadState: true,
          retries: 10,
          timeLimit: const Duration(seconds: 100),
          timeRetry: const Duration(seconds: 5)),
    );
  }

  Widget _bodyWidget() {
    return GridView.builder(
      itemCount: catalogItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10),
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
          child: Column(
            children: [
              _imageHolder(index),
              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      catalogItems[index]["discount_percent"],
                      style: const TextStyle(
                          color: ColorStyle.certificated,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(
                      "${catalogItems[index]["price"]}원",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Row(
                  children: [
                    Text(
                      catalogItems[index]["unit_price"],
                      style: const TextStyle(fontSize: 13),
                    )
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: _bodyWidget(),
    );
  }
}
