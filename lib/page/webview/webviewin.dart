import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewIn extends StatefulWidget {
  String mylink;
  WebViewIn({super.key, required this.mylink});

  @override
  State<WebViewIn> createState() => _WebViewInState();
}

class _WebViewInState extends State<WebViewIn> {
  @override
  Widget build(BuildContext context) {
    return WebView(
      initialUrl: widget.mylink,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
