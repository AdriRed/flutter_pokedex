import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SessionModel extends ChangeNotifier {
  UserData _user;
  FavouritesData _favourites;
  int _customIndex;
  int _favouritesIndex;

  Favourite get selectedFavourite =>
      favouritesData.favourites[_favouritesIndex];
  // Favourite get selectedCustom => favouritesData.favourites[_customIndex];

  bool get hasUserData => userData != null;
  bool get hasFavouritesData => _favourites != null;
  UserData get userData => _user;
  FavouritesData get favouritesData => _favourites;
  int get favouritesIndex => _favouritesIndex;

  static SessionModel of(BuildContext context, {bool listen = false}) =>
      Provider.of<SessionModel>(context, listen: listen);

  Future setUserData(UserData data) {
    return Future.sync(() {
      _user = data;
      notifyListeners();
    });
  }

  Future removeUserData() {
    return setUserData(null);
  }

  Future addFavourite(int id) {
    return Future.sync(() {
      _favourites.favourites.add(new Favourite(pokemonId: id));
      notifyListeners();
    });
  }

  Future removeFavourite(int id) {
    return Future.sync(() {
      _favourites.favourites.removeWhere((element) => element.pokemonId == id);
      notifyListeners();
    });
  }

  Future setFavouritesData(FavouritesData data) {
    return Future.sync(() {
      _favourites = data;
      notifyListeners();
    });
  }

  Future removeFavouritesData() {
    return setFavouritesData(null);
  }

  void setFavouritesIndex(int index) {
    _favouritesIndex = index;

    notifyListeners();
  }

  void setCustomIndex(int index) {
    _customIndex = index;

    notifyListeners();
  }
}

class UserData {
  final String username;
  final String email;
  final String photo;
  final String token;

  UserData({this.username, this.email, this.photo, this.token});
}

class FavouritesData {
  List<Favourite> favourites;

  FavouritesData({this.favourites});
}

class Favourite {
  int pokemonId;

  Favourite({this.pokemonId});
}
