import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:pokedex/apimodels/PokemonBaseType.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';
import 'package:pokedex/consumers/PokeIndex.dart';
import 'package:provider/provider.dart';

class PokeapiModel extends ChangeNotifier {
  static String _host = "pokeapi.co"; //"192.168.0.21:5001";
  static String _innerRoute = "api/v2"; //"pokeapi";
  final ApiConsumer<PokeIndex> _pokemons = new ApiConsumer(
      "https://" + _host + "/" + _innerRoute + "/pokemon-species?limit=-1");

  final List<ApiConsumer<PokemonBaseType>> _types = Iterable.generate(
      18,
      (i) => ApiConsumer<PokemonBaseType>("https://" +
          _host +
          "/" +
          _innerRoute +
          "/type/" +
          (i + 1).toString())).toList();

  int _selectedIndex = 0;

  UnmodifiableListView<ApiConsumer<PokemonSpecies>> get pokemons =>
      UnmodifiableListView(_pokemons.info.entries.map((x) => x.species));

  bool get hasData => _pokemons.hasInfo;
  bool get hasTypesData => _types.every((element) => element.hasInfo);

  ApiConsumer<PokemonSpecies> get pokemonSpecies =>
      _pokemons.info.entries[_selectedIndex].species;

  PokeIndex get pokeIndex => _pokemons.info;

  UnmodifiableListView<ApiConsumer<PokemonBaseType>> get pokemonTypes =>
      UnmodifiableListView(_types);

  int get index => _selectedIndex;

  static PokeapiModel of(BuildContext context, {bool listen = false}) =>
      Provider.of<PokeapiModel>(context, listen: listen);

  Future<void> init() async {
    await _pokemons.getInfo();

    notifyListeners();
  }

  Future<void> initTypes() async {
    await Future.wait(_types.map((x) => x.getInfo()));

    notifyListeners();
  }

  void setSelectedIndex(int index) {
    _selectedIndex = index;

    notifyListeners();
  }
}
