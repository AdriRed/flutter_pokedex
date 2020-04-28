import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/apimodels/PokemonChainLink.dart';
import 'package:pokedex/apimodels/PokemonEvolutionChain.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';
import 'package:pokedex/consumers/PokemonLoader.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:provider/provider.dart';

import '../../../configs/AppColors.dart';
import '../../../models/pokemon.dart';

class PokemonBall extends StatelessWidget {
  PokemonBall(this._consumer, {Key key}) : super(key: key);

  final ApiConsumer<PokemonSpecies> _consumer;
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final pokeballSize = screenHeight * 0.1;
    final pokemonSize = pokeballSize * 0.85;

    return FutureBuilder(
      future:
          _consumer.getInfo().then((x) => x.defaultVariety.pokemon.getInfo()),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Image.asset(
                  "assets/images/pokeball.png",
                  width: pokeballSize,
                  height: pokeballSize,
                  color: AppColors.lightGrey,
                ),
                CachedNetworkImage(
                  placeholder: (ctx, str) => Image.asset(
                    "assets/images/8bit-pokeball.png",
                    filterQuality: FilterQuality.none,
                    fit: BoxFit.contain,
                    width: pokemonSize,
                    height: pokemonSize,
                    alignment: Alignment.center,
                  ),
                  placeholderFadeInDuration: Duration(milliseconds: 250),
                  imageUrl: _consumer.info.defaultVariety.pokemon.info.hdSprite,
                  imageBuilder: (_, image) => Image(
                    image: image,
                    width: pokemonSize,
                    height: pokemonSize,
                  ),
                )
              ],
            ),
            SizedBox(height: 3),
            Text(_consumer.info.names["es"]),
          ],
        );
      },
    );
  }
}

class PokemonEvolution extends StatelessWidget {
  Widget _buildRow(
      {ApiConsumer<PokemonSpecies> current,
      ApiConsumer<PokemonSpecies> next,
      reason: String}) {
    return Row(
      children: <Widget>[
        Expanded(child: PokemonBall(current)),
        Expanded(
          child: Column(
            children: <Widget>[
              Icon(Icons.arrow_forward, color: AppColors.lightGrey),
              SizedBox(height: 7),
              Text(
                reason,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Expanded(child: PokemonBall(next)),
      ],
    );
  }

  Widget _buildDivider() {
    return Column(
      children: <Widget>[
        SizedBox(height: 21),
        Divider(),
        SizedBox(height: 21),
      ],
    );
  }

  List<Widget> evolutions(PokemonChainLink chain) {
    List<Widget> widgets = new List();

    if (chain.evolutions.length == 0) return null;

    for (var evo in chain.evolutions) {
      widgets.add(_buildRow(current: chain.specie, next: evo.specie));
      widgets.addAll(evolutions(evo));
    }
    return widgets;
  }

  List<Widget> buildEvolutionList(PokemonChainLink chain) {
    if (chain.evolutions.length <= 0) {
      return [
        Center(child: Text("No evolution")),
      ];
    }

    List<Widget> evos = evolutions(chain).where((x) => x != null);

    return evos.expand((widget) => [widget, _buildDivider()]).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cardController = Provider.of<AnimationController>(context);

    return AnimatedBuilder(
      animation: cardController,
      child: Consumer<PokeapiModel>(
        builder: (_, model, child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              "Evolution Chain",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 16, height: 0.8),
            ),
            SizedBox(height: 28),
            ...buildEvolutionList(
                model.pokemonSpecies.info.evolutionChain.info.chain),
          ],
        ),
      ),
      builder: (context, widget) {
        final scrollable = cardController.value.floor() == 1;

        return SingleChildScrollView(
          physics: scrollable
              ? BouncingScrollPhysics()
              : NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(vertical: 31, horizontal: 28),
          child: widget,
        );
      },
    );
  }
}
