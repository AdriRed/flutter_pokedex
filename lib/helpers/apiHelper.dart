import 'dart:io';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart' as ioclient;
import 'package:meta/meta.dart';
import 'package:http/http.dart';

class ApiHelper {
  static const String apiUrl = 'http://sds-pokedex-api.azurewebsites.net';
  // static const String apiUrl = 'https://192.168.0.18:5001';

  static HttpClient _ioClient = new HttpClient()
    ..badCertificateCallback = (_, __, ___) => true;

  static ioclient.IOClient _client = new ioclient.IOClient(_ioClient);

  static Future call(ApiOptions options) async {
    try {
      Response response;
      switch (options.method) {
        case ApiOptionsMethods.get:
          response =
              await _client.get(apiUrl + options.url, headers: options.headers);
          break;
        case ApiOptionsMethods.post:
          response = await _client.post(apiUrl + options.url,
              headers: options.headers, body: options.body);
          break;
        case ApiOptionsMethods.put:
          response = await _client.put(apiUrl + options.url,
              headers: options.headers, body: options.body);
          break;
        case ApiOptionsMethods.delete:
          response = await _client.delete(apiUrl + options.url,
              headers: options.headers);
          break;
        default:
          throw new Exception(
              "Not implemented method " + options.method.toString());
      }
      if (response.statusCode == 200)
        options.onSuccess?.call(response.body, response.statusCode);
      else
        options.onFailure?.call(response.body, response.statusCode);
    } catch (e) {
      options.onFailure?.call(e.runtimeType.toString(), -1);
    } finally {
      options.onFinally?.call();
    }
  }
}

enum ApiOptionsMethods { get, post, put, delete }

class ApiOptions {
  final ApiOptionsMethods method;
  final String url;
  final String body;
  final Map<String, String> headers;
  final Function(String, int) onSuccess;
  final Function(String, int) onFailure;
  final Function() onFinally;

  ApiOptions(
      {@required this.method,
      @required this.url,
      this.body,
      this.headers,
      this.onSuccess,
      this.onFailure,
      this.onFinally});
}
