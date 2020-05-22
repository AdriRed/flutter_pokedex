import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/screens/pokedex_api/widgets/generation_modal.dart';
import 'package:pokedex/screens/pokedex_api/widgets/search_modal.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
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
    final double height = MediaQuery.of(context).size.height;
    final double width = MediaQuery.of(context).size.width;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => SearchBottomModal(
        onSubmit: (search) {
          log(search);
          if (search.trim() == "") return;
          Navigator.of(context).pop();

          var model = PokeapiModel.of(context)
              .pokeIndex
              .entries
              .where((x) => x.name.contains(search.trim()))
              .toList();

          showDialog(
              context: context,
              child: AlertDialog(
                title: Text("Results of " + search),
                scrollable: true,
                contentPadding: EdgeInsets.all(10),
                content: Container(
                  height: height * 0.8,
                  width: width * 0.85,
                  child: GridView.builder(
                    padding: EdgeInsets.only(left: 0, right: 0, bottom: 58),
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: model.length,
                    itemBuilder: (context, index) => PokemonApiCard(
                      model[index].species,
                      index: index,
                      onPress: () {
                        // Navigator.of(context).pop(index);
                      },
                    ),
                  ),
                ),
              ));
        },
      ),
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
            Navigator.of(context).popAndPushNamed("/favourites");
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

  Widget _buildPage(BuildContext context, {Widget child, bool action}) {
    return Scaffold(
        body: Stack(
          children: <Widget>[
            CustomPokeContainer(
              appBar: [
                GestureDetector(
                  child: Icon(Icons.arrow_back),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
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
        floatingActionButton: action ? _buildActionButtons(context) : null);
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading) {
      return _buildPage(context,
          child: Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          action: false);
    }

    return _buildPage(
      context,
      child: _buildList(context),
      action: true,
    );
  }
}
