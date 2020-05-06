import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart' as ioclient;

class LoginHelper {
  static Future login(String user, String password) async {
    log(user + ":" + password);
    var ioClient = new HttpClient()
      ..badCertificateCallback = (_, __, ___) => true;

    var client = new ioclient.IOClient(ioClient);
    var url = "https://192.168.0.18:5001/api/Account/login";
    var body =
        '{\"email\": \"' + user + '\", \"password\": \"' + password + '\"}';

    try {
      var response = await client
          .post(url, body: body, headers: {'Content-Type': 'application/json'});
      log(response.body);
      if (response.statusCode == 200) {
        var body = json.decode(response.body);
        log("RESPONSE OK!: " + body["token"]);
      }
    } catch (e) {}
  }
}
