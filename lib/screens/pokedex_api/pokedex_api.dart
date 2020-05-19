import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/screens/pokedex_api/widgets/generation_modal.dart';
import 'package:pokedex/screens/pokedex_api/widgets/search_modal.dart';
import 'package:pokedex/widgets/fab.dart';
import 'package:pokedex/widgets/poke_container.dart';
import 'package:pokedex/widgets/pokemon_api_card.dart';
import 'package:provider/provider.dart';

class PokedexApi extends StatefulWidget {
  @override
  _PokedexApiState createState() => _PokedexApiState();
}

class _PokedexApiState extends State<PokedexApi>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _animationController;
  bool _loading;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);

    _loading = !PokeapiModel.of(context).hasData;
    super.initState();
  }

  @override
  void didChangeDependencies() {
    PokeapiModel pokeapiModel = PokeapiModel.of(context, listen: true);

    if (!pokeapiModel.hasData) {
      pokeapiModel.init().then((_) => this.setState(() => _loading = false));
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

  Widget _buildList(BuildContext context) {
    return Consumer<PokeapiModel>(
      builder: (context, pokeapiModel, child) => Expanded(
        child: GridView.builder(
          physics: BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          padding: EdgeInsets.only(left: 28, right: 28, bottom: 58),
          itemCount: pokeapiModel.pokemons.length,
          itemBuilder: (context, index) => PokemonApiCard(
            pokeapiModel.pokemons[index],
            index: index,
            onPress: () {
              pokeapiModel.setSelectedIndex(index);
              Navigator.of(context).pushNamed("/pokeapi-info");
            },
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return ExpandedAnimationFab(
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
    );
  }

  Widget _buildPage(BuildContext context, {Widget child}) {
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
                // list here
                child
              ],
            ),
            _buildOverlayBackground(),
          ],
        ),
        floatingActionButton: _buildActionButtons(context));
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading) {
      return _buildPage(
        context,
        child: Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return _buildPage(context, child: _buildList(context));
  }
}
