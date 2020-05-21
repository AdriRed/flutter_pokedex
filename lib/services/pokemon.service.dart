import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:pokedex/helpers/apiHelper.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/token.handler.dart';

class PokemonHelper {
  static Future getFavouites(Function(FavouritesData data) onSuccess,
      Function(String body) onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.get,
        url: '/api/pokemon/favourites',
        headers: {'Authorization': await TokenHandler.getHeaderToken()},
        onSuccess: (body, code) {
          var jsonresult = json.decode(body);
          var result = jsonresult as List<dynamic>;
          FavouritesData data = new FavouritesData(
              favourites: result.length == 0
                  ? new List()
                  : result
                      .map(
                        (x) => new Favourite(
                          pokemonId: x["favouritePokemonId"],
                        ),
                      )
                      .toList());

          onSuccess?.call(data);
        },
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }

  static Future addFavourite(int id, Function(Favourite favourite) onSuccess,
      Function(String body) onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.post,
        url: '/api/pokemon/favourites',
        body: json.encode({"favouritePokemonId": id}),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await TokenHandler.getHeaderToken()
        },
        onSuccess: (body, code) {
          var result = json.decode(body);

          onSuccess?.call(
            new Favourite(
              pokemonId: result["favouritePokemonId"],
            ),
          );
        },
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }

  static Future removeFavourite(int id, Function(Favourite favourite) onSuccess,
      Function(String body) onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.delete,
        url: '/api/pokemon/favourites/' + id.toString(),
        headers: {'Authorization': await TokenHandler.getHeaderToken()},
        onSuccess: (body, code) {
          var result = json.decode(body);

          onSuccess?.call(
            new Favourite(
              pokemonId: result["favouritePokemonId"],
            ),
          );
        },
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }

  static Future addCustom(
      String name,
      Uint8List photo,
      int type1,
      int type2,
      Function(Custom favourite) onSuccess,
      Function(String body) onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.post,
        url: '/api/pokemon/custom/',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await TokenHandler.getHeaderToken()
        },
        body: json.encode({
          "name": name,
          "photo": base64Encode(photo),
          "type1": type1,
          "type2": type2
        }),
        onSuccess: (body, code) {
          var result = json.decode(body);

          onSuccess?.call(
            new Custom(
              result["id"],
              result["photo"],
              result["name"],
              result["type1"],
              result["type2"],
            ),
          );
        },
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }

  static Future removeCustom(int id, Function(Custom favourite) onSuccess,
      Function(String body) onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.delete,
        url: '/api/pokemon/custom/' + id.toString(),
        headers: {'Authorization': await TokenHandler.getHeaderToken()},
        onSuccess: (body, code) {
          var result = json.decode(body);

          onSuccess?.call(
            new Custom(
              result["id"],
              result["photo"],
              result["name"],
              result["type1"],
              result["type2"],
            ),
          );
        },
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }

  static Future getMyCustom(Function(CustomsData favourite) onSuccess,
      Function(String body) onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.get,
        url: '/api/pokemon/custom/self',
        headers: {'Authorization': await TokenHandler.getHeaderToken()},
        onSuccess: (body, code) {
          var jsonresult = json.decode(body);
          var result = jsonresult as List<dynamic>;
          CustomsData data = new CustomsData(
              customs: result.length == 0
                  ? new List()
                  : result
                      .map(
                        (x) => new Custom(
                          x["id"],
                          x["photo"],
                          x["name"],
                          x["type1"],
                          x["type2"],
                        ),
                      )
                      .toList());

          onSuccess?.call(data);
        },
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }

  static Future getOthersCustom(
      String url,
      Function(CustomsData favourite) onSuccess,
      Function(String body) onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.get,
        url: url.split(ApiHelper.apiUrl).last,
        headers: {'Authorization': await TokenHandler.getHeaderToken()},
        onSuccess: (body, code) {
          var jsonresult = json.decode(body);
          var result = jsonresult as List<dynamic>;
          CustomsData data = new CustomsData(
              customs: result.length == 0
                  ? new List()
                  : result
                      .map(
                        (x) => new Custom(
                          x["id"],
                          x["photo"],
                          x["name"],
                          x["type1"],
                          x["type2"],
                        ),
                      )
                      .toList());

          onSuccess?.call(data);
        },
        onFailure: (body, create) => {onFailure?.call(body)});

    return ApiHelper.call(options);
  }
}
