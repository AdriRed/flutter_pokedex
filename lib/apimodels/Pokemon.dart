import 'dart:developer';

import 'Model.dart';
import '../consumers/ApiConsumer.dart';
import 'PokemonBaseStat.dart';

import 'PokemonBaseAbility.dart';
import 'PokemonSpecies.dart';
import 'PokemonBaseType.dart';

class Pokemon implements Model {
  int id;
  //Provider<PokemonSpecies> specie;
  List<PokemonStat> stats;
  Map<String, String> sprites;
  String hdSprite;
  List<PokemonType> types;
  List<PokemonAbility> abilities;

  int height, weight;
  int baseExperience;

  Pokemon.fromJSON(Map<String, dynamic> json) {
    id = json["id"];
    height = json["height"];
    weight = json["weight"];
    baseExperience = json["base_experience"];
    stats = new List();
    sprites = new Map();
    types = new List();
    abilities = new List();
    hdSprite = "https://assets.pokemon.com/assets/cms2/img/pokedex/full/" +
        (id / 100).toStringAsFixed(2).replaceAll(".", "") +
        ".png";

    for (var stat in json["stats"]) {
      stats.add(new PokemonStat.fromJSON(stat));
    }
    for (var type in json["types"]) {
      types.add(new PokemonType.fromJSON(type));
    }
    for (var ability in json["abilities"]) {
      abilities.add(new PokemonAbility.fromJSON(ability));
    }

    json["sprites"].forEach((k, v) {
      if (v != null) sprites.putIfAbsent(k, () => v);
    });
    types.sort((x, y) => x.slot - y.slot);
  }
}

class PokemonAbility {
  ApiConsumer<PokemonBaseAbility> ability;
  bool isHidden;
  int slot;

  PokemonAbility.fromJSON(Map<String, dynamic> json) {
    ability = new ApiConsumer(json["ability"]["url"]);
    isHidden = json["is_hidden"];
    slot = json["slot"];
  }
}

class PokemonType {
  int slot;
  ApiConsumer<PokemonBaseType> type;

  PokemonType.fromJSON(Map<String, dynamic> json) {
    slot = json["slot"];
    type = new ApiConsumer(json["type"]["url"]);
  }
}

class PokemonStat {
  ApiConsumer<PokemonBaseStat> stat;
  int value;

  PokemonStat.fromJSON(Map<String, dynamic> json) {
    this.value = json["base_stat"];
    stat = new ApiConsumer(json["stat"]["url"]);
  }
}
