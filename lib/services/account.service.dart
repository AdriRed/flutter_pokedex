import 'dart:convert';

import 'package:pokedex/helpers/apiHelper.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/token.handler.dart';

class AccountHelper {
  static Future login(String user, String password, Function onSuccess,
      Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.post,
        url: '/api/account/login',
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
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }

  static Future create(String user, String password, String repeated,
      Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.post,
        url: '/api/account/register',
        body: json.encode({
          'username': user,
          'email': user,
          'password': password,
          'repeatPassword': repeated
        }),
        headers: {'Content-Type': 'application/json'},
        onSuccess: (body, code) {
          var result = json.decode(body);

          UserData data = UserData(
            token: result['token'],
            username: result['username'],
            photo: result['photo'],
            email: result['email'],
          );

          TokenHandler.setToken(data.token).then((_) => onSuccess?.call(data));
        },
        onFailure: (body, code) => onFailure?.call(body));

    return ApiHelper.call(options);
  }

  static Future edit(
      UserData data, Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.put,
        url: '/api/account/edit',
        body: json.encode({
          'email': data.email,
          'username': data.username,
          'photo': data.photo,
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
        onFailure: (body, code) => onFailure?.call(body));

    return ApiHelper.call(options);
  }

  static Future changePassword(String newP, String repeatP, Function onSuccess,
      Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.put,
        url: '/api/account/changepassword',
        body: json.encode({
          'password': newP,
          'repeatPassword': repeatP,
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
        onFailure: (body, code) => onFailure?.call(body));

    return ApiHelper.call(options);
  }

  static Future self(Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.get,
        url: '/api/account/self',
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
        onFailure: (body, code) => onFailure?.call(body));

    return ApiHelper.call(options);
  }
}
