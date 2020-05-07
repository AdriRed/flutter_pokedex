import 'package:shared_preferences/shared_preferences.dart';

class TokenHandler {
  static const String _token = 'token';

  static Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_token);
  }

  static Future setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_token, token);
  }

  static Future<String> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }

  static Future<String> getHeaderToken() async {
    String token = await getToken();
    return 'Bearer ' + token;
  }

  static Future removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(_token);
  }
}
