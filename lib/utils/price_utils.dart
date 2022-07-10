import 'package:intl/intl.dart';

class PriceUtils {
  static final oCcy = NumberFormat("#,###", "ko_KR");
  static String calcStringToWon(String priceString) {
    // if (priceString == "무료나눔") return priceString;
    return "${oCcy.format(int.parse(priceString))}원/묶음";
  }
}
