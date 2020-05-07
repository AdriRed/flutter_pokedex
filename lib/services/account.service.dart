import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:http/http.dart';
import 'package:http/io_client.dart' as ioclient;
import 'package:meta/meta.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/token.handler.dart';

class AccountHelper {
  static Future login(String user, String password, Function onSuccess,
      Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.post,
        url: 'https://192.168.0.18:5001/api/account/login',
        body: json.encode({'email': user, 'password': password}),
        headers: {'Content-Type': 'application/json'},
        onSuccess: (body, code) {
          var result = json.decode(body);

          UserData data = UserData(
            token: result['token'],
            username: result['username'],
            photo: result['photo'],
            email: result['email'],
          );

          TokenHandler.setToken(data.token).then((_) => onSuccess(data));
        },
        onFailure: (body, create) => {onFailure?.call()});

    ApiHelper.call(options);
  }

  static Future create(String user, String password, String repeated,
      Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.post,
        url: 'https://192.168.0.18:5001/api/account/login',
        body: json.encode({'email': user, 'password': password}),
        headers: {'Content-Type': 'application/json'},
        onSuccess: (body, code) {
          var result = json.decode(body);

          UserData data = UserData(
            token: result['token'],
            username: result['username'],
            photo: result['photo'],
            email: result['email'],
          );

          TokenHandler.setToken(data.token).then((_) => onSuccess(data));
        },
        onFailure: (body, code) => onFailure?.call());

    ApiHelper.call(options);
  }

  static Future edit(String email, String password, String repeated,
      Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.put,
        url: 'https://192.168.0.18:5001/api/account/edit',
        body: json.encode({
          'email': email,
          'password': password,
          'repeatPassword': repeated,
          'username': email
        }),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await TokenHandler.getHeaderToken()
        },
        onSuccess: (body, code) {
          var result = json.decode(body);
          UserData data = UserData(
            token: result['token'],
            username: result['username'],
            photo: result['photo'],
            email: result['email'],
          );

          onSuccess?.call(data);
        },
        onFailure: (body, code) => onFailure());

    ApiHelper.call(options);
  }

  static Future self(Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.get,
        url: 'https://192.168.0.18:5001/api/account/self',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await TokenHandler.getHeaderToken()
        },
        onSuccess: (body, code) {
          var result = json.decode(body);
          UserData data = UserData(
            token: result['token'],
            username: result['username'],
            photo: result['photo'],
            email: result['email'],
          );

          onSuccess?.call(data);
        },
        onFailure: (body, code) => onFailure());

    ApiHelper.call(options);
  }
}

class ApiHelper {
  static HttpClient _ioClient = new HttpClient()
    ..badCertificateCallback = (_, __, ___) => true;

  static ioclient.IOClient _client = new ioclient.IOClient(_ioClient);

  static Future call(ApiOptions options) async {
    try {
      Response response;
      switch (options.method) {
        case ApiOptionsMethods.get:
          response = await _client.get(options.url, headers: options.headers);
          break;
        case ApiOptionsMethods.post:
          response = await _client.post(options.url,
              headers: options.headers, body: options.body);
          break;
        case ApiOptionsMethods.put:
          response = await _client.put(options.url,
              headers: options.headers, body: options.body);
          break;
        case ApiOptionsMethods.delete:
          response = await _client.put(options.url, headers: options.headers);
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
