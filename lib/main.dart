import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/detail.dart';
import 'package:chocobread/page/login.dart';
import 'package:chocobread/page/nicknameset.dart';
import 'package:chocobread/page/repository/content_repository.dart';
import 'package:chocobread/page/splash/splash.dart';
import 'package:chocobread/page/termscheck.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:chocobread/page/routes.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';

import 'firebase_options.dart';

// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

Future<void> setupInteractedMessage() async {
    // Get any messages which caused the application to open from
    // a terminated state.
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    FirebaseMessaging.onMessage.listen(_handleMessage);
  }

  void _handleMessage(RemoteMessage message) async{
    // 여기서 Navigator 작업
    // if (message.data['type'] == 'chat') {
    //   Navigator.pushNamed(context, '/chat',
    //     arguments: ChatArguments(message),
    //   );
    // }
    if (message.data['type'] == 'deal'){
      // 채은 : 디테일 상세 페이지 이동
      print("이건 DEAL 이다");
      print(message.data);
      var temp = await loadContentByDealId(int.parse(message.data['dealId']));
        Get.to(() => DetailContentView(data: temp, isFromHome: true));
      // message.data['dealId'] <- 여기로 거래 상세 이동.
    }
  }

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  print("Handling a background message: ${message.messageId}");
  // _handleMessage(message);
}

const snackBar = SnackBar(
  content: Text(
    "위치 권한이 거부된 상태입니다. 앱 설정에서 위치 권한을 허용해주세요.",
    style: TextStyle(color: Colors.white),
  ),
  backgroundColor: ColorStyle.darkMainColor,
  duration: Duration(milliseconds: 2000),
  behavior: SnackBarBehavior.floating,
  elevation: 50,
  shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(
    Radius.circular(5),
  )),
);

Future<void> main() async {
  KakaoSdk.init(nativeAppKey: 'cfd53361fe092dba3d8960f5697f97b4');
  WidgetsFlutterBinding
      .ensureInitialized(); // SharePreferences 랑 Firebase Analytics 가 초기 설정될 때 정상적으로 동작하게 하기 위한 것
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  setupInteractedMessage();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter 1/N',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        scaffoldBackgroundColor:
            Colors.white, // 모든 scaffold 의 background color 는 white
        primaryColor: ColorStyle.mainColor,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            systemOverlayStyle: SystemUiOverlayStyle(
              statusBarIconBrightness: Brightness.dark,
              statusBarBrightness: Brightness.light,
            )),
        outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
                primary: ColorStyle.mainColor,
                side: const BorderSide(width: 1.0, color: ColorStyle.mainColor),
                textStyle: const TextStyle(
                    // color: Colors.green,
                    fontSize: 16,
                    fontWeight: FontWeight.w300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                )
                // const StadiumBorder(),
                )),
        colorScheme:
            ThemeData().colorScheme.copyWith(primary: ColorStyle.mainColor),

        // primaryColor: Colors.white,
        // primarySwatch: Colors.green,
      ),
      initialRoute: '/splash', // 앱에 첫 화면을 지정하는 속성
      routes: {
        '/splash': (context) => Splash(),
        '/login': (context) => Login(),
        '/termscheck': (context) => TermsCheck(),
        '/nicknameset': (context) => NicknameSet(),
      }, // navigation 화면들을 등록하는 부분
      // 영어로 된 time picker, date picker 한글로 변환
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      debugShowCheckedModeBanner: false, // Hide the debug banner
      home: const App(),
    );
  }
}
