import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/consumers/PokemonLoader.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:provider/provider.dart';

import '../../models/pokemon.dart';
import '../../widgets/slide_up_panel.dart';
import 'widgets/info.dart';
import 'widgets/tab.dart';

import '../../helpers/HelperMethods.dart';

class PokeapiInfo extends StatefulWidget {
  const PokeapiInfo();

  @override
  _PokeapiInfoState createState() => _PokeapiInfoState();
}

class _PokeapiInfoState extends State<PokeapiInfo>
    with TickerProviderStateMixin {
  static const double _pokemonSlideOverflow = 20;

  AnimationController _cardController;
  AnimationController _cardHeightController;
  double _cardMaxHeight = 0.0;
  double _cardMinHeight = 0.0;
  GlobalKey _pokemonInfoKey = GlobalKey();

  @override
  void dispose() {
    _cardController.dispose();
    _cardHeightController.dispose();
    PokeapiModel.of(context).removeListener(changePokemon);

    super.dispose();
  }

  @override
  void initState() {
    _cardController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _cardHeightController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 220));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      final appBarHeight = 60 + 22 + IconTheme.of(context).size;

      final RenderBox pokemonInfoBox =
          _pokemonInfoKey.currentContext.findRenderObject();

      _cardMinHeight =
          screenHeight - pokemonInfoBox.size.height + _pokemonSlideOverflow;
      _cardMaxHeight = screenHeight - appBarHeight;

      _cardHeightController.forward();
    });

    PokeapiModel.of(context).addListener(changePokemon);
    _loaded = false;
    super.initState();
  }

  bool _loaded;

  void concatToFuture(Future f, Function after) {
    log("concat " + after.toString());
    f.then(after);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // _loadedStats = false;
    // changePokemon();
  }

  void changePokemon() {
    var specie = PokeapiModel.of(context).pokemonSpecies;
    Future fut = Future.value();

    specie.info ?? fut.then((_) => specie.getInfo());

    specie.info?.defaultVariety?.pokemon?.info ??
        //fut.then((_) => specie.info.defaultVariety.pokemon.getInfo());
        concatToFuture(
            fut, (_) => specie.info.defaultVariety.pokemon.getInfo());

    specie.info?.eggGroups?.every((x) => x.hasInfo) ?? false
        ? true
        : null ??
            // fut.then((_) =>
            //     Future.wait(specie.info.eggGroups.map((x) => x.getInfo())));
            concatToFuture(
                fut,
                (_) =>
                    Future.wait(specie.info.eggGroups.map((x) => x.getInfo())));

    specie.info?.evolutionChain?.info ??
        // fut.then((_) => PokemonLoader.futureEvolution(specie.info));
        concatToFuture(
            fut,
            (_) => specie.info.evolutionChain
                .getInfo()
                .then((chain) => chain.chain.getAllInfo()));

    specie.info?.defaultVariety?.pokemon?.info?.stats
                ?.every((x) => x.stat.hasInfo) ??
            false
        ? true
        : null ??
            // fut.then((_) => Future.wait(specie
            //     .info.defaultVariety.pokemon.info.stats
            //     .map((x) => x.stat.getInfo())));
            concatToFuture(
                fut,
                (_) => Future.wait(specie.info.defaultVariety.pokemon.info.stats
                    .map((x) => x.stat.getInfo())));

    specie.info?.defaultVariety?.pokemon?.info?.types
                ?.every((x) => x.type.hasInfo) ??
            false
        ? true
        : null ??
            // fut.then((_) => Future.wait(specie
            //     .info.defaultVariety.pokemon.info.types
            //     .map((x) => x.type.getInfo())));
            concatToFuture(
                fut,
                (_) => Future.wait(specie.info.defaultVariety.pokemon.info.types
                    .map((x) => x.type.getInfo())));

    fut.then((_) {
      log("loaded this");
      this.setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableProvider(
      builder: (context) => _cardController,
      child: MultiProvider(
        providers: [ListenableProvider.value(value: _cardController)],
        child: Scaffold(
          body: Consumer<PokeapiModel>(
            builder: (_, model, child) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                color: model.pokemonSpecies.info?.defaultVariety?.pokemon?.info
                            ?.types
                            ?.tryGet(0)
                            ?.type
                            ?.info !=
                        null
                    ? AppColors.types[model.pokemonSpecies.info.defaultVariety
                            .pokemon.info.types[0].type.info.id -
                        1]
                    : AppColors.grey,
                child: Stack(
                  children: <Widget>[
                    AnimatedBuilder(
                      animation: _cardHeightController,
                      child: model.pokemonSpecies.info?.defaultVariety?.pokemon
                                  ?.info?.types
                                  ?.tryGet(0)
                                  ?.type
                                  ?.info !=
                              null
                          // child: false
                          ? PokemonTabInfo()
                          : Center(
                              child: CircularProgressIndicator(),
                            ),
                      builder: (context, child) {
                        return SlidingUpPanel(
                          controller: _cardController,
                          minHeight:
                              _cardMinHeight * _cardHeightController.value,
                          maxHeight: _cardMaxHeight,
                          child: child,
                        );
                      },
                    ),
                    IntrinsicHeight(
                      child: Container(
                        key: _pokemonInfoKey,
                        child: PokemonOverallInfo(),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
