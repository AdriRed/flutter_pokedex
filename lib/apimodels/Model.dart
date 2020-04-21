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
    //log("factory: " + type.toString());
    switch (type) {
      case Pokemon:
        Pokemon a = new Pokemon.fromJSON(json);
        return a;
        break;
      case PokemonBaseAbility:
        return new PokemonBaseAbility.fromJSON(json);
        break;
      case PokemonEvolutionChain:
        return new PokemonEvolutionChain.fromJSON(json);
        break;
      case PokemonSpecies:
        PokemonSpecies a = new PokemonSpecies.fromJSON(json);
        return a;
        break;
      case PokemonBaseStat:
        return new PokemonBaseStat.fromJSON(json);
        break;
      case PokemonBaseType:
        return new PokemonBaseType.fromJSON(json);
      case PokeIndex:
        return new PokeIndex.fromJSON(json);
        break;
      case PokemonGeneration:
        return new PokemonGeneration.fromJSON(json);
        break;
      case PokemonSpeciesList:
        return new PokemonSpeciesList.fromJSON(json);
        break;
    }

    throw Exception("Not valid type");
  }
}
