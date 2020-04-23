import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/consumers/PokemonSpeciesProvider.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/screens/pokedex/widgets/generation_modal.dart';
import 'package:pokedex/screens/pokedex/widgets/search_modal.dart';
import 'package:pokedex/widgets/fab.dart';
import 'package:pokedex/widgets/poke_container.dart';
import 'package:pokedex/widgets/pokemon_api_card.dart';
import 'package:pokedex/widgets/pokemon_card.dart';
import 'package:provider/provider.dart';

class PokedexApi extends StatefulWidget {
  @override
  _PokedexApiState createState() => _PokedexApiState();
}

class _PokedexApiState extends State<PokedexApi>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _animationController;
  PokemonSpeciesProvider provider = new PokemonSpeciesProvider();

  PageController _pageController =
      new PageController(viewportFraction: 0.4, keepPage: true);

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    _pageController.addListener(() {
      if (_pageController.position.pixels >=
          _pageController.position.maxScrollExtent - 200) {
        provider.getMore();
      }
    });

    super.initState();
  }

  void _showSearchModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchBottomModal(),
    );
  }

  void _showGenerationModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => GenerationModal(),
    );
  }

  Widget _buildOverlayBackground() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return IgnorePointer(
          ignoring: _animation.value == 0,
          child: InkWell(
            onTap: () => _animationController.reverse(),
            child: Container(
              color: Colors.black.withOpacity(_animation.value * 0.5),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          PokeContainer(
            appBar: true,
            children: <Widget>[
              SizedBox(height: 34),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.0),
                child: Text(
                  "Pokedex API",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 32),
              FutureBuilder(
                  future: provider.initIndex(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Expanded(
                        child: GridView.builder(
                          physics: BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 1.4,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                          ),
                          padding:
                              EdgeInsets.only(left: 28, right: 28, bottom: 58),
                          itemCount: provider.index.entries.length,
                          itemBuilder: (context, index) => PokemonApiCard(
                            provider.index.entries[index].species,
                            index: index + 1,
                            onPress: () {
                              // pokemonModel.setSelectedIndex(index);
                              // Navigator.of(context).pushNamed("/pokemon-info");
                              log("details of " + (index + 1).toString());
                            },
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Icon(Icons.mood_bad),
                      );
                    }
                    return Center(
                        child: Column(
                      children: <Widget>[
                        CircularProgressIndicator(),
                        Text("Loading provider...")
                      ],
                    ));
                  }),
              // Consumer<PokemonModel>(
              //   builder: (context, pokemonModel, child) => Expanded(
              //     child: GridView.builder(
              //       physics: BouncingScrollPhysics(),
              //       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              //         crossAxisCount: 2,
              //         childAspectRatio: 1.4,
              //         crossAxisSpacing: 10,
              //         mainAxisSpacing: 10,
              //       ),
              //       padding: EdgeInsets.only(left: 28, right: 28, bottom: 58),
              //       itemCount: pokemonModel.pokemons.length,
              //       itemBuilder: (context, index) => PokemonCard(
              //         pokemonModel.pokemons[index],
              //         index: index,
              //         onPress: () {
              //           // pokemonModel.setSelectedIndex(index);
              //           // Navigator.of(context).pushNamed("/pokemon-info");
              //         },
              //       ),
              //     ),
              //   ),
              // ),
            ],
          ),
          _buildOverlayBackground(),
        ],
      ),
      floatingActionButton: ExpandedAnimationFab(
        items: [
          FabItem(
            "Favourite Pokemon",
            Icons.favorite,
            onPress: () {
              _animationController.reverse();
            },
          ),
          FabItem(
            "All Type",
            Icons.filter_vintage,
            onPress: () {
              _animationController.reverse();
            },
          ),
          FabItem(
            "All Gen",
            Icons.flash_on,
            onPress: () {
              _animationController.reverse();
              _showGenerationModal();
            },
          ),
          FabItem(
            "Search",
            Icons.search,
            onPress: () {
              _animationController.reverse();
              _showSearchModal();
            },
          ),
        ],
        animation: _animation,
        onPress: _animationController.isCompleted
            ? _animationController.reverse
            : _animationController.forward,
      ),
    );
  }
}
