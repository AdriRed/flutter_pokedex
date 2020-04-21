import '../consumers/ApiConsumer.dart';
import 'Model.dart';
import 'PokemonSpecies.dart';

class PokemonSpeciesList implements Model {
  List<ApiConsumer<PokemonSpecies>> species;
  int count;

  PokemonSpeciesList.fromJSON(Map<String, dynamic> json,
      {String field = "results"}) {
    count = json["count"];
    species = new List();
    for (var pokemonSpecie in json[field]) {
      species.add(new ApiConsumer(pokemonSpecie["url"]));
    }
  }
}
