import 'dart:collection';
import 'dart:developer';

import '../apimodels/Model.dart';
import '../apimodels/PokemonSpecies.dart';

import 'ApiConsumer.dart';

class PokeEntry {
  ApiConsumer<PokemonSpecies> species;
  String name;
  int id;

  PokeEntry.fromJSON(Map<String, dynamic> json, int id) {
    name = json["name"];
    species = new ApiConsumer(json["url"]);
    this.id = id;
  }
}

class PokeIndex implements Model {
  List<PokeEntry> entries = new List();
  Queue<PokeEntry> order;
  int _count = 0;

  List<ApiConsumer<PokemonSpecies>> fetch(int many) {
    // log("Fetching " + many.toString());
    // var list = entries.sublist(_count, many+1).map((item) {return item.species;}).toList();
    // _count += many;
    // log("Total " + _count.toString());
    var list = new List<ApiConsumer<PokemonSpecies>>();
    for (var i = 0; i < many; i++) {
      list.add(order.removeFirst().species);
    }

    return list;
  }

  PokeIndex.fromJSON(Map<String, dynamic> json) {
    for (var i = 0; i < json["results"].length; i++) {
      entries.add(new PokeEntry.fromJSON(json["results"][i], i + 1));
    }
    order = new Queue.from(entries);
  }
}
