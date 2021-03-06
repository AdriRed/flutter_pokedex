import '../consumers/ApiConsumer.dart';

import 'Model.dart';
import 'PokemonSpecies.dart';

class PokemonGeneration implements Model {
  int id;
  String initials;
  String name;
  Map<String, String> names;
  List<ApiConsumer<PokemonSpecies>> pokemonSpecies;

  PokemonGeneration.fromJSON(Map<String, dynamic> json) {
    id = json["id"];
    name = json["name"];
    initials = name.substring(name.indexOf("-") + 1);
    for (var lan in json["names"]) {
      names.putIfAbsent(lan["language"]["name"], () => lan["name"]);
    }

    for (var poke in json["pokemon_species"]) {
      pokemonSpecies.add(new ApiConsumer(poke["url"]));
    }

    pokemonSpecies.sort((a, b) => (a.url.toString().split("/")[6] as int)
        .compareTo(b.url.toString().split("/")[6] as int));
  }
}
