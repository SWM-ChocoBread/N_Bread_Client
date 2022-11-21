import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CatalogWebview extends StatefulWidget {
  String url;
  CatalogWebview({super.key, required this.url});

  @override
  State<CatalogWebview> createState() => _CatalogWebviewState();
}

class _CatalogWebviewState extends State<CatalogWebview> {
  PreferredSizeWidget _appbarWidget() {
    return AppBar(
      elevation: 0,
      // bottomOpacity: 10,
      backgroundColor: ColorStyle.ongoing,
      centerTitle: true,
      titleSpacing: 20,
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
      title: Padding(
        padding: const EdgeInsets.only(right: 50.0),
        child: Center(
          child: ElevatedButton(
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text("이 상품 N빵하기"),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbarWidget(),
      body: SafeArea(
        child: WebView(
          initialUrl: widget.url,
          javascriptMode: JavascriptMode.unrestricted,
        ),
      ),
    );
  }
}
