import 'dart:developer';
import 'dart:convert';
import 'Model.dart';
import '../consumers/ApiConsumer.dart';

import 'PokemonEvolutionChain.dart';

import 'Pokemon.dart';

class PokemonSpecies implements Model {
  int id;
  int order;
  Map<String, String> names;
  Map<String, String> descriptionEntries;
  Map<String, String> genera;
  List<PokemonVariety> varieties;
  ApiConsumer<PokemonEvolutionChain> evolutionChain;

  PokemonSpecies.fromJSON(Map<String, dynamic> json) {
    //log(json["name"]);
    id = json["id"];
    order = json["order"];

    names = new Map();
    descriptionEntries = new Map();
    genera = new Map();
    varieties = new List();

    for (var name in json["names"])
      names.putIfAbsent(name["language"]["name"], () => name["name"]);
    for (var flavor in json["flavor_text_entries"])
      descriptionEntries.putIfAbsent(
          flavor["language"]["name"], () => flavor["flavor_text"]);
    for (var genus in json["genera"])
      genera.putIfAbsent(genus["language"]["name"], () => genus["genus"]);
    for (var variety in json["varieties"])
      varieties.add(new PokemonVariety.fromJSON(variety));

    evolutionChain = new ApiConsumer(json["evolution_chain"]["url"]);

    varieties.sort((a, b) => (b.isDefault ? 1 : 0) - (a.isDefault ? 1 : 0));
  }

  PokemonVariety get defaultVariety {
    return varieties.singleWhere((x) => x.isDefault);
  }
}

class PokemonVariety {
  bool isDefault;
  ApiConsumer<Pokemon> pokemon;

  PokemonVariety.fromJSON(Map<String, dynamic> json) {
    isDefault = json["is_default"];
    pokemon = new ApiConsumer(json["pokemon"]["url"]);
  }

  int compareTo(PokemonVariety other) {
    if (this.isDefault)
      return 1;
    else
      return -1;
  }
}
