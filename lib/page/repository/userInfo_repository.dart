import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoRepository {
  Future<Map<String, dynamic>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("userToken");
    print("userInfo function's token is ${token}");

    if (token != null) {
      Map<String, dynamic> payload = Jwt.parseJwt(token);
      return payload;
    } else {
      print("token is null");
      Map<String, dynamic> fail = {"key": "value"};
      return fail;
    }
  }
}
