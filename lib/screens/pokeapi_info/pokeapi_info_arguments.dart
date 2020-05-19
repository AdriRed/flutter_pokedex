import 'package:flutter/cupertino.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';

class PokeapiInfoArguments extends ChangeNotifier {
  PokeapiInfoArguments({this.index, this.pokemons});

  int index;
  final List<ApiConsumer<PokemonSpecies>> pokemons;

  void setIndex(int changedIndex) {
    index = changedIndex;
    notifyListeners();
  }
}
