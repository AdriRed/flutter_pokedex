import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

class SessionModel extends ChangeNotifier {
  UserData _user;
  FavouritesData _favourites;
  CustomsData _customs;

  int _customsIndex;
  int _favouritesIndex;

  Favourite get selectedFavourite =>
      favouritesData.favourites[_favouritesIndex];
  // Favourite get selectedCustom => favouritesData.favourites[_customIndex];

  bool get hasUserData => userData != null;
  bool get hasCustomsData => _customs != null;
  bool get hasFavouritesData => _favourites != null;

  UserData get userData => _user;
  CustomsData get customsData => _customs;
  FavouritesData get favouritesData => _favourites;

  int get favouritesIndex => _favouritesIndex;
  int get customsIndex => _customsIndex;

  static SessionModel of(BuildContext context, {bool listen = false}) =>
      Provider.of<SessionModel>(context, listen: listen);

  Future setUserData(UserData data) {
    return Future.sync(() {
      _user = data;
      notifyListeners();
    });
  }

  Future cleanEverything() {
    return Future.wait(
        [removeUserData(), removeFavouritesData(), removeCustomsData()]);
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

  Future addCustom(Custom data) {
    return Future.sync(() {
      _customs.customs.add(data);
      notifyListeners();
    });
  }

  Future removeCustom(int id) {
    return Future.sync(() {
      _customs.customs.removeWhere((element) => element.id == id);
      notifyListeners();
    });
  }

  Future setFavouritesData(FavouritesData data) {
    return Future.sync(() {
      _favourites = data;
      notifyListeners();
    });
  }

  Future setCustomsData(CustomsData data) {
    return Future.sync(() {
      _customs = data;
      notifyListeners();
    });
  }

  Future removeFavouritesData() {
    return setFavouritesData(null);
  }

  Future removeCustomsData() {
    return setCustomsData(null);
  }

  void setFavouritesIndex(int index) {
    _favouritesIndex = index;

    notifyListeners();
  }

  void setCustomIndex(int index) {
    _customsIndex = index;

    notifyListeners();
  }
}

class UserData {
  final int id;
  final String username;
  final String email;
  final String photo;
  final String token;

  UserData({this.username, this.email, this.photo, this.token, this.id = 0});
}

class CustomsData {
  List<Custom> customs;

  CustomsData({this.customs});
}

class FavouritesData {
  List<Favourite> favourites;

  FavouritesData({this.favourites});
}

class Custom {
  final int id;
  final String photo;
  final String name;
  final int type1;
  final int type2;
  const Custom(this.id, this.photo, this.name, this.type1, this.type2);
}

class Favourite {
  int pokemonId;

  Favourite({this.pokemonId});
}
