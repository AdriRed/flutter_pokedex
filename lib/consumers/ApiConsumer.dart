import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:developer';
import 'package:pokedex/apimodels/Pokemon.dart';
import 'package:pokedex/apimodels/PokemonBaseType.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';

import '../apimodels/Model.dart';

import 'Locker.dart';

class ApiConsumer<T extends Model> {
  Uri url;
  T info;

  Locker _locker = LockManager.getLocker();
  static Repository repo = new Repository();

  bool get hasInfo {
    return info != null;
  }

  Future<T> getInfo() async {
    if (hasInfo) {
      _locker.unlock();
      return info;
    }

    if (repo.exists(url.toString())) {
      info = await repo.pop(url.toString()) as T;
      _locker.unlock();
      return info;
    }

    _recall() {
      return getInfo();
    }

    if (_locker.locked) return await _locker.waitLock();
    _locker.setFunction(_recall);
    _locker.lock();

    try {
      HttpClient http = new HttpClient()
        ..badCertificateCallback = (_, __, ___) => true;
      final resp = await http.getUrl(url);
      final respbody = await resp.close();
      if (respbody.statusCode != 200) {
        _locker.unlock();
        return await getInfo();
      }

      final converted = await respbody.transform(utf8.decoder).join();
      final decoded = json.decode(converted);
      T object = new Model.fromJSON(T, decoded);
      info = object;
    } catch (e) {
      log(e.toString());
      _locker.unlock();
      return null;
    }
    repo.add(url.toString(), info);
    _locker.unlock();
    return info;
  }

  ApiConsumer(String struri) {
    url = Uri.parse(struri);
  }

  ApiConsumer.uri(Uri uri) {
    url = uri;
  }
}

class Repository {
  Map<String, dynamic> _repo = new Map();

  bool exists(String k) {
    return _repo.containsKey(k);
  }

  void add(String k, dynamic v) {
    log(k);
    _repo.putIfAbsent(k, () => v);
  }

  Future<dynamic> pop(String k) async {
    if (!_repo.containsKey(k)) return null;
    return _repo[k];
  }
}
