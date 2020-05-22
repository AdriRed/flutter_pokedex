import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/screens/pokedex_api/widgets/generation_modal.dart';
import 'package:pokedex/screens/pokedex_api/widgets/search_modal.dart';
import 'package:pokedex/services/pokemon.service.dart';
import 'package:pokedex/services/token.handler.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
import 'package:pokedex/widgets/fab.dart';
import 'package:pokedex/widgets/poke_container.dart';
import 'package:pokedex/widgets/pokemon_api_card.dart';
import 'package:provider/provider.dart';

class FavouritesPage extends StatefulWidget {
  FavouritesPage({Key key}) : super(key: key);

  @override
  _FavouritesPageState createState() => _FavouritesPageState();
}

class _FavouritesPageState extends State<FavouritesPage>
    with SingleTickerProviderStateMixin {
  Animation<double> _animation;
  AnimationController _animationController;
  bool _loading;
  bool _loggedIn;

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 260),
    );

    final curvedAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    _loggedIn = false;

    TokenHandler.isLoggedIn.then((value) {
      if (!value)
        Navigator.of(context).popAndPushNamed('/login');
      else {
        PokeapiModel pokeapiModel = PokeapiModel.of(context);
        SessionModel sessionModel = SessionModel.of(context);
        this.setState(() {
          _loggedIn = value;
          _loading = !(value &&
              pokeapiModel.hasData &&
              sessionModel.hasFavouritesData);
        });
        Future.wait(
          [
            pokeapiModel.init(),
            PokemonHelper.getFavouites(
                (data) => sessionModel.setFavouritesData(data), (x) {
              showSnackbar(x);
              log("Error loading favourites");
            }),
          ],
        ).then(
          (value) => setState(
            () {
              _loading = false;
            },
          ),
        );
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

  GlobalKey<ScaffoldState> _globalKey = new GlobalKey();
  void showSnackbar(String message) {
    _globalKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: "Dismiss",
          onPressed: () => _globalKey.currentState.hideCurrentSnackBar(),
        ),
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
    if (!_loggedIn)
      return Expanded(
        child: Container(),
      );
    return Consumer2<PokeapiModel, SessionModel>(
      builder: (context, pokeapiModel, sessionModel, child) {
        var list = pokeapiModel.pokeIndex.entries
            .where((element) => sessionModel.favouritesData.favourites
                .any((x) => x.pokemonId == element.id))
            .toList()
            .reversed
            .toList();
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
            itemCount: list.length,
            itemBuilder: (context, index) => PokemonApiCard(
              list[index].species,
              index: index,
              onPress: () {
                sessionModel.setFavouritesIndex(index);
                Navigator.of(context).pushNamed("/favourites-info");
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildPage(BuildContext context, {Widget child}) {
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
                  "Favourites",
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
    );
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading ?? false) {
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
