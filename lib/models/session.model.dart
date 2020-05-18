import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SessionModel extends ChangeNotifier {
  UserData _data;

  bool get hasData => data != null;
  UserData get data => _data;

  static SessionModel of(BuildContext context, {bool listen = false}) =>
      Provider.of<SessionModel>(context, listen: listen);

  Future setNewData(UserData data) {
    return Future.sync(() {
      _data = data;
      notifyListeners();
    });
  }

  Future removeData() {
    return setNewData(null);
  }
}

class UserData {
  final String username;
  final String email;
  final String photo;
  final String token;

  UserData({this.username, this.email, this.photo, this.token});
}
