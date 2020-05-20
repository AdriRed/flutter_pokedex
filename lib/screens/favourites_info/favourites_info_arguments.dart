import 'package:flutter/cupertino.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';

class FavouritesInfoArguments extends ChangeNotifier {
  FavouritesInfoArguments({this.index, this.pokemons});

  int index;
  final List<ApiConsumer<PokemonSpecies>> pokemons;

  void setIndex(int changedIndex) {
    index = changedIndex;
    notifyListeners();
  }
}
