import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/screens/customs/widgets/customs_api_card.dart';
import 'package:pokedex/services/pokemon.service.dart';
import 'package:pokedex/services/token.handler.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
import 'package:pokedex/widgets/poke_container.dart';
import 'package:provider/provider.dart';

class CustomsPage extends StatefulWidget {
  CustomsPage({Key key}) : super(key: key);

  @override
  _CustomsPageState createState() => _CustomsPageState();
}

class _CustomsPageState extends State<CustomsPage>
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
              pokeapiModel.hasTypesData &&
              sessionModel.hasCustomsData);
        });
        Future.wait(
          [
            PokemonHelper.getMyCustom(
                (data) => sessionModel.setCustomsData(data),
                (_) => {log("Error loading customs")}),
            pokeapiModel.initTypes(),
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
        var list = sessionModel.customsData.customs;
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
            itemBuilder: (context, index) => CustomsApiCard(
              index: list[index].id,
              image: base64Decode(list[index].photo),
              name: list[index].name,
              type1: pokeapiModel.pokemonTypes
                  .firstWhere((element) => element.info.id == list[index].type1)
                  .info,
              type2: pokeapiModel.pokemonTypes
                  .firstWhere((element) => element.info.id == list[index].type2)
                  .info,
              // onPress: () {
              //   sessionModel.setFavouritesIndex(index);
              //   Navigator.of(context).pushNamed("/favourites-info");
              // },
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
            appBar: <Widget>[
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Icon(Icons.arrow_back),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed("/customs-add");
                },
                child: Icon(Icons.add),
              ),
            ],
            children: <Widget>[
              SizedBox(height: 34),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.0),
                child: Text(
                  "Your custom pokemon",
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
