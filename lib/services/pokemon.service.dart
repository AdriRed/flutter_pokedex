import 'dart:convert';
import 'dart:developer';

import 'package:pokedex/helpers/apiHelper.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/token.handler.dart';

class PokemonHelper {
  static Future getFavouites(Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.get,
        url: '/api/pokemon/favourites',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': await TokenHandler.getHeaderToken()
        },
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

  static Future addFavourite(
      int id, Function onSuccess, Function onFailure) async {
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

  static Future removeFavourite(
      int id, Function onSuccess, Function onFailure) async {
    ApiOptions options = ApiOptions(
        method: ApiOptionsMethods.delete,
        url: '/api/pokemon/favourites/' + id.toString(),
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
}
