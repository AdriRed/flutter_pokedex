import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/pokemon.service.dart';
import 'package:pokedex/services/token.handler.dart';
import 'package:pokedex/widgets/pokemon_api_card.dart';
import 'package:provider/provider.dart';

import '../../../widgets/animated_fade.dart';
import '../../../widgets/animated_rotation.dart';
import '../../../widgets/animated_slide.dart';
import '../../../widgets/pokemon_type.dart';
import 'decoration_box.dart';

import '../../../helpers/HelperMethods.dart';

class PokemonOverallInfo extends StatefulWidget {
  const PokemonOverallInfo();

  @override
  _PokemonOverallInfoState createState() => _PokemonOverallInfoState();
}

class _PokemonOverallInfoState extends State<PokemonOverallInfo>
    with TickerProviderStateMixin {
  double textDiffLeft = 0.0;
  double textDiffTop = 0.0;

  static const double _appBarBottomPadding = 22.0;
  static const double _appBarHorizontalPadding = 28.0;
  static const double _appBarTopPadding = 60.0;

  GlobalKey _currentTextKey = GlobalKey();
  PageController _pageController;
  AnimationController _rotateController;
  AnimationController _slideController;
  GlobalKey _targetTextKey = GlobalKey();

  bool _loggedIn;
  bool _loadedFavourites;

  @override
  void dispose() {
    _slideController?.dispose();
    _rotateController?.dispose();
    _pageController?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _slideController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 360));
    _slideController.forward();

    _rotateController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 5000));
    _rotateController.repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox targetTextBox =
          _targetTextKey.currentContext.findRenderObject();
      final Offset targetTextPosition =
          targetTextBox.localToGlobal(Offset.zero);

      final RenderBox currentTextBox =
          _currentTextKey.currentContext.findRenderObject();
      final Offset currentTextPosition =
          currentTextBox.localToGlobal(Offset.zero);

      textDiffLeft = targetTextPosition.dx - currentTextPosition.dx;
      textDiffTop = targetTextPosition.dy - currentTextPosition.dy;
    });

    _loggedIn = false;
    _loadedFavourites = false;

    TokenHandler.isLoggedIn.then((value) {
      this.setState(() {
        _loggedIn = value;
      });
      if (value) {
        if (!SessionModel.of(context).hasFavouritesData)
          PokemonHelper.getFavouites(
            (data) {
              SessionModel.of(context)
                  .setFavouritesData(data)
                  .then((_) => this.setState(() {
                        _loadedFavourites = true;
                      }));
            },
            (_) {
              log("Error loading favourites");
            },
          );
        else
          this.setState(() {
            _loadedFavourites = true;
          });
      }
    });

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_pageController == null) {
      PokeapiModel pokeapiModel = PokeapiModel.of(context);

      _pageController = PageController(
          viewportFraction: 0.6, initialPage: pokeapiModel.index);
      _pageController.addListener(() {
        int next = _pageController.page.round();

        if (pokeapiModel.index != next) {
          pokeapiModel.setSelectedIndex(next);
        }
      });
    }

    super.didChangeDependencies();
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.only(
        left: _appBarHorizontalPadding,
        right: _appBarHorizontalPadding,
        top: _appBarTopPadding,
        bottom: _appBarBottomPadding,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              InkWell(
                child: Icon(Icons.arrow_back, color: Colors.white),
                onTap: Navigator.of(context).pop,
              ),
              _loggedIn && _loadedFavourites
                  ? Consumer2<PokeapiModel, SessionModel>(
                      builder: (context, pokemon, session, child) {
                        return session.favouritesData.favourites.any((x) =>
                                x.pokemonId == pokemon.pokemonSpecies.info.id)
                            ? GestureDetector(
                                onTap: () => this._removeFromFavourites(
                                    pokemon.pokemonSpecies.info.id),
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                ),
                              )
                            : GestureDetector(
                                onTap: () => this._addToFavourites(
                                    pokemon.pokemonSpecies.info.id),
                                child: Icon(
                                  Icons.favorite_border,
                                  color: Colors.white,
                                ),
                              );
                      },
                    )
                  : Container()
            ],
          ),
          // This widget just sit here for easily calculate the new position of
          // the pokemon name when the card scroll up
          Opacity(
            opacity: 0.0,
            child: Text(
              "Bulbasaur",
              key: _targetTextKey,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addToFavourites(int id) {
    PokemonHelper.addFavourite(
        id,
        (favourite) => SessionModel.of(context).addFavourite(id),
        (body) => log("error adding " + id.toString()));
  }

  void _removeFromFavourites(int id) {
    PokemonHelper.removeFavourite(
        id,
        (favourite) => SessionModel.of(context).removeFavourite(id),
        (body) => log("error removing " + id.toString()));
  }

  Widget _buildPokemonName(PokemonSpecies pokemon) {
    final cardScrollController = Provider.of<AnimationController>(context);
    final fadeAnimation =
        Tween(begin: 1.0, end: 0.0).animate(cardScrollController);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 26),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          AnimatedBuilder(
            animation: cardScrollController,
            builder: (context, child) {
              final double value = cardScrollController.value ?? 0.0;

              return Transform.translate(
                offset: Offset(textDiffLeft * value, textDiffTop * value),
                child: Hero(
                  tag: pokemon?.names?.tryGetValue("es") ??
                      "not-loaded-pokemon-name",
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      pokemon?.names?.tryGetValue("es") ?? "",
                      key: _currentTextKey,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 36 - (36 - 22) * value,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          AnimatedFade(
            animation: fadeAnimation,
            child: AnimatedSlide(
              animation: _slideController,
              child: Hero(
                tag: pokemon?.id ?? "not-loaded-id",
                child: Material(
                  color: Colors.transparent,
                  child: Text(
                    pokemon?.id?.toString() ?? "",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonTypes(PokemonSpecies pokemon) {
    final cardScrollController = Provider.of<AnimationController>(context);
    final fadeAnimation =
        Tween(begin: 1.0, end: 0.0).animate(cardScrollController);

    return AnimatedFade(
      animation: fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              children: pokemon?.defaultVariety?.pokemon?.info?.types
                      ?.map((type) => Hero(
                          tag: type,
                          child: PokemonApiCardType(
                              type?.type?.info?.names?.tryGetValue("es") ?? "",
                              large: true)))
                      ?.toList() ??
                  [PokemonApiCardType("", large: true)],
            ),
            AnimatedSlide(
              animation: _slideController,
              child: Text(
                pokemon?.genera?.tryGetValue("es") ?? "",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPokemonSlider(BuildContext context, PokemonSpecies pokemon,
      List<ApiConsumer<PokemonSpecies>> pokemons) {
    final screenSize = MediaQuery.of(context).size;
    final cardScrollController = Provider.of<AnimationController>(context);
    final fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: cardScrollController,
        curve: Interval(
          0.0,
          0.5,
          curve: Curves.ease,
        ),
      ),
    );

    final selectedIndex = PokeapiModel.of(context).index;

    return AnimatedFade(
      animation: fadeAnimation,
      child: SizedBox(
        width: screenSize.width,
        height: screenSize.height * 0.24,
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedRotation(
                animation: _rotateController,
                child: Image.asset(
                  "assets/images/pokeball.png",
                  width: screenSize.height * 0.24,
                  height: screenSize.height * 0.24,
                  color: Colors.white.withOpacity(0.14),
                ),
              ),
            ),
            PageView.builder(
              physics: BouncingScrollPhysics(),
              controller: _pageController,
              itemCount: pokemons.length,
              onPageChanged: (index) {
                PokeapiModel.of(context).setSelectedIndex(index);
              },
              itemBuilder: (context, index) => Hero(
                tag: pokemons[index]
                        .info
                        ?.defaultVariety
                        ?.pokemon
                        ?.info
                        ?.hdSprite ??
                    "not-loaded-specie-" + index.toString(),
                child: AnimatedPadding(
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeOutQuint,
                  padding: EdgeInsets.only(
                    top: selectedIndex == index ? 0 : screenSize.height * 0.04,
                    bottom:
                        selectedIndex == index ? 0 : screenSize.height * 0.04,
                  ),
                  child: pokemons[index]
                              .info
                              ?.defaultVariety
                              ?.pokemon
                              ?.info
                              ?.hdSprite ==
                          null
                      ? Image.asset(
                          "assets/images/8bit-pokeball.png",
                          filterQuality: FilterQuality.none,
                          fit: BoxFit.contain,
                          width: screenSize.height * 0.28,
                          height: screenSize.height * 0.28,
                          alignment: Alignment.bottomCenter,
                          color: selectedIndex == index ? null : Colors.black26,
                        )
                      : CachedNetworkImage(
                          imageUrl: pokemons[index]
                              .info
                              .defaultVariety
                              .pokemon
                              .info
                              .hdSprite,
                          placeholder: (ctx, str) => Image.asset(
                            "assets/images/8bit-pokeball.png",
                            filterQuality: FilterQuality.none,
                            fit: BoxFit.contain,
                            width: screenSize.height * 0.28,
                            height: screenSize.height * 0.28,
                            alignment: Alignment.bottomCenter,
                            color:
                                selectedIndex == index ? null : Colors.black26,
                          ),
                          placeholderFadeInDuration:
                              Duration(milliseconds: 250),
                          imageBuilder: (context, image) => Image(
                            image: image,
                            width: screenSize.height * 0.28,
                            height: screenSize.height * 0.28,
                            alignment: Alignment.bottomCenter,
                            color:
                                selectedIndex == index ? null : Colors.black26,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorations() {
    final screenSize = MediaQuery.of(context).size;

    final cardScrollController = Provider.of<AnimationController>(context);
    final dottedAnimation =
        Tween(begin: 1.0, end: 0.0).animate(cardScrollController);

    final pokeSize = screenSize.width * 0.448;
    final pokeTop =
        -(pokeSize / 2 - (IconTheme.of(context).size / 2 + _appBarTopPadding));
    final pokeRight = -(pokeSize / 2 -
        (IconTheme.of(context).size / 2 + _appBarHorizontalPadding));

    return [
      Positioned(
        top: pokeTop,
        right: pokeRight,
        child: AnimatedFade(
          animation: cardScrollController,
          child: AnimatedRotation(
            animation: _rotateController,
            child: Image.asset(
              "assets/images/pokeball.png",
              width: pokeSize,
              height: pokeSize,
              color: Colors.white.withOpacity(0.26),
            ),
          ),
        ),
      ),
      Positioned(
        top: -screenSize.height * 0.055,
        left: -screenSize.height * 0.055,
        child: DecorationBox(),
      ),
      Positioned(
        top: 4,
        left: screenSize.height * 0.3,
        child: AnimatedFade(
          animation: dottedAnimation,
          child: Image.asset(
            "assets/images/dotted.png",
            width: screenSize.height * 0.07,
            height: screenSize.height * 0.07 * 0.54,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ..._buildDecorations(),
        Consumer<PokeapiModel>(
          builder: (_, model, child) => Column(
            children: <Widget>[
              _buildAppBar(),
              SizedBox(height: 9),
              _buildPokemonName(model.pokemonSpecies.info),
              SizedBox(height: 9),
              _buildPokemonTypes(model.pokemonSpecies.info),
              SizedBox(height: 25),
              _buildPokemonSlider(
                  context, model.pokemonSpecies.info, model.pokemons),
            ],
          ),
        ),
      ],
    );
  }
}
