import 'package:flutter/cupertino.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';

import '../../models/pokemon.dart';

class PokemonInfoArguments extends ChangeNotifier {
  PokemonInfoArguments({this.index, this.pokemons});

  int index;
  final List<ApiConsumer<PokemonSpecies>> pokemons;

  void setIndex(int changedIndex) {
    index = changedIndex;
    notifyListeners();
  }
}
