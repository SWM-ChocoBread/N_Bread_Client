import 'package:jwt_decode/jwt_decode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserInfoRepository {
  Future<Map<String, dynamic>> getUserInfo() async {
    await Future.delayed(const Duration(microseconds: 1), (){});
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("tmpUserToken");

    
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
