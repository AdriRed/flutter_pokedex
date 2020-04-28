import 'dart:developer';

import 'Pokemon.dart';
import 'PokemonBaseAbility.dart';
import 'PokemonEvolutionChain.dart';
import 'PokemonGeneration.dart';
import 'PokemonSpecies.dart';
import 'PokemonBaseStat.dart';
import 'PokemonBaseType.dart';
import 'PokemonSpeciesList.dart';
import '../consumers/PokeIndex.dart';

abstract class Model {
  factory Model.fromJSON(Type type, Map<String, dynamic> json) {
    // log("factory: " + type.toString());

    switch (type) {
      case Pokemon:
        return new Pokemon.fromJSON(json);
      case PokemonBaseAbility:
        return new PokemonBaseAbility.fromJSON(json);
      case PokemonEvolutionChain:
        return new PokemonEvolutionChain.fromJSON(json);
      case PokemonSpecies:
        return new PokemonSpecies.fromJSON(json);
      case PokemonBaseStat:
        return new PokemonBaseStat.fromJSON(json);
      case PokemonBaseType:
        return new PokemonBaseType.fromJSON(json);
      case PokeIndex:
        return new PokeIndex.fromJSON(json);
      case PokemonGeneration:
        return new PokemonGeneration.fromJSON(json);
      case PokemonSpeciesList:
        return new PokemonSpeciesList.fromJSON(json);
      case PokemonEggGroup:
        return new PokemonEggGroup.fromJSON(json);
    }

    throw Exception("Not valid type");
  }
}
