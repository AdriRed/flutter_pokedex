import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:pokedex/navigations/navigation.dart';

import '../../data/pokemons.dart';
import '../../models/pokemon.dart';
import '../../widgets/fab.dart';
import '../../widgets/poke_container.dart';
import '../../widgets/pokemon_card.dart';
import 'widgets/generation_modal.dart';
import 'widgets/search_modal.dart';

class Pokedex extends StatefulWidget {
  const Pokedex();

  @override
  _PokedexState createState() => _PokedexState();
}

class _PokedexState extends State<Pokedex> with SingleTickerProviderStateMixin {
  final _pokemonBloc = PokemonBloc.instance();

  Animation<double> _animation;
  AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (!_pokemonBloc.hasPokemons) {
      getPokemonsList(context).then(_pokemonBloc.setPokemons);
    }

    super.didChangeDependencies();
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
                  "Pokedex",
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 32),
              StreamBuilder(
                stream: _pokemonBloc.pokemonsStream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final pokemons = snapshot.data;

                  return Expanded(
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      padding: EdgeInsets.only(left: 28, right: 28, bottom: 58),
                      itemCount: pokemons.length,
                      itemBuilder: (context, index) => PokemonCard(
                        pokemons[index],
                        index: index,
                        onPress: () {
                          _pokemonBloc.setCurrentPokemon(pokemons[index]);
                          AppNavigation.instance().push(Routes.pokemonInfo);
                        },
                      ),
                    ),
                  );
                },
              ),
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
