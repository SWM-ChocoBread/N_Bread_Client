import 'package:chocobread/page/app.dart';
import 'package:chocobread/page/splash/splash.dart';
import 'package:chocobread/style/colorstyles.dart';
import 'package:flutter/material.dart';
import 'package:chocobread/page/routes.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
        primaryColor: ColorStyle.mainColor,
        appBarTheme: const AppBarTheme(
            backgroundColor: Colors.white, foregroundColor: Colors.black),
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
      // initialRoute: Splash.routeName, // 앱에 첫 화면을 지정하는 속성
      // routes: routeSplash, // navigation 화면들을 등록하는 부분
      // 영어로 된 time picker, date picker 한글로 변환
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
      home: const App(),
    );
  }
}
