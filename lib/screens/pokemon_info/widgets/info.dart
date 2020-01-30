import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/navigations/navigation.dart';

import '../../../models/pokemon.dart';
import '../../../widgets/animated_fade.dart';
import '../../../widgets/animated_rotation.dart';
import '../../../widgets/animated_slide.dart';
import '../../../widgets/pokemon_type.dart';
import '../pokemon_info.dart';
import 'decoration_box.dart';

class PokemonOverallInfo extends StatefulWidget {
  const PokemonOverallInfo();

  @override
  _PokemonOverallInfoState createState() => _PokemonOverallInfoState();
}

class _PokemonOverallInfoState extends State<PokemonOverallInfo>
    with TickerProviderStateMixin {
  final _pokemonBloc = PokemonBloc.instance();

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

  @override
  dispose() {
    _slideController?.dispose();
    _rotateController?.dispose();
    _pageController?.dispose();

    super.dispose();
  }

  @override
  void initState() {
    _slideController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 360),
    );
    _slideController.forward();

    _rotateController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 5000),
    );
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

    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_pageController == null) {
      _pageController = PageController(
        viewportFraction: 0.6,
        initialPage: _pokemonBloc.currentPokemonIndex,
      );

      _pageController.addListener(() {
        int nextIndex = _pageController.page.round();

        if (_pokemonBloc.currentPokemonIndex != nextIndex) {
          _pokemonBloc.setCurrentPokemon(_pokemonBloc.pokemons[nextIndex]);
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
                onTap: AppNavigation.instance().pop,
              ),
              Icon(Icons.favorite_border, color: Colors.white),
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

  Widget _buildPokemonName() {
    final cardScrollController = PokemonCardController.of(context).controller;
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
                child: Container(
                  key: _currentTextKey,
                  child: StreamBuilder(
                    stream: _pokemonBloc.currentPokemonStream,
                    builder: (_, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final pokemon = snapshot.data;

                      return Material(
                        color: Colors.transparent,
                        child: Hero(
                          tag: pokemon.name,
                          child: Text(
                            pokemon.name,
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 36 - (36 - 22) * value,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          StreamBuilder<Pokemon>(
            stream: _pokemonBloc.currentPokemonStream,
            builder: (_, snapshot) {
              if (!snapshot.hasData) {
                return Center(child: CircularProgressIndicator());
              }

              final pokemon = snapshot.data;

              return AnimatedFade(
                animation: fadeAnimation,
                child: AnimatedSlide(
                  animation: _slideController,
                  child: Hero(
                    tag: pokemon.id,
                    child: Material(
                      color: Colors.transparent,
                      child: Text(
                        pokemon.id,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPokemonTypes() {
    final cardScrollController = PokemonCardController.of(context).controller;
    final fadeAnimation =
        Tween(begin: 1.0, end: 0.0).animate(cardScrollController);

    return AnimatedFade(
      animation: fadeAnimation,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 26),
        child: StreamBuilder<Pokemon>(
          stream: _pokemonBloc.currentPokemonStream,
          builder: (_, snapshot) {
            if (!snapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }

            final pokemon = snapshot.data;

            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  children: pokemon.types
                      .map((type) => Hero(
                          tag: type, child: PokemonType(type, large: true)))
                      .toList(),
                ),
                AnimatedSlide(
                  animation: _slideController,
                  child: Text(
                    pokemon.category,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildPokemonSlider(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final cardScrollController = PokemonCardController.of(context).controller;
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

    final pokemons = _pokemonBloc.pokemons;

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
                _pokemonBloc.setCurrentPokemon(pokemons[index]);
              },
              itemBuilder: (context, index) => Hero(
                tag: pokemons[index].image,
                child: StreamBuilder(
                  stream: _pokemonBloc.currentPokemonStream,
                  builder: (_, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }

                    final selectedIndex = _pokemonBloc.currentPokemonIndex;

                    return AnimatedPadding(
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeOutQuint,
                      padding: EdgeInsets.only(
                        top: selectedIndex == index
                            ? 0
                            : screenSize.height * 0.04,
                        bottom: selectedIndex == index
                            ? 0
                            : screenSize.height * 0.04,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: pokemons[index].image,
                        imageBuilder: (context, image) => Image(
                          image: image,
                          width: screenSize.height * 0.28,
                          height: screenSize.height * 0.28,
                          alignment: Alignment.bottomCenter,
                          color: selectedIndex == index ? null : Colors.black26,
                        ),
                      ),
                    );
                  },
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

    final cardScrollController = PokemonCardController.of(context).controller;
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
        Column(
          children: <Widget>[
            _buildAppBar(),
            SizedBox(height: 9),
            _buildPokemonName(),
            SizedBox(height: 9),
            _buildPokemonTypes(),
            SizedBox(height: 25),
            _buildPokemonSlider(context),
          ],
        ),
      ],
    );
  }
}
