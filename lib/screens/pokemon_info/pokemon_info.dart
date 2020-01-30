import 'package:flutter/material.dart';

import '../../models/pokemon.dart';
import '../../widgets/slide_up_panel.dart';
import 'widgets/info.dart';
import 'widgets/tab.dart';

class PokemonInfo extends StatefulWidget {
  const PokemonInfo();

  @override
  _PokemonInfoState createState() => _PokemonInfoState();
}

class _PokemonInfoState extends State<PokemonInfo>
    with TickerProviderStateMixin {
  static const double _pokemonSlideOverflow = 20;

  final _pokemonBloc = PokemonBloc.instance();

  AnimationController _cardController;
  AnimationController _cardHeightController;
  double _cardMaxHeight = 0;
  double _cardMinHeight = 0;
  GlobalKey _pokemonInfoKey = GlobalKey();

  @override
  void initState() {
    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _cardHeightController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 220),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initCardSize();
    });

    super.initState();
  }

  @override
  void dispose() {
    _cardController.dispose();
    _cardHeightController.dispose();

    super.dispose();
  }

  void _initCardSize() {
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = 60 + 22 + IconTheme.of(context).size;

    final RenderBox pokemonInfoBox =
        _pokemonInfoKey.currentContext.findRenderObject();

    _cardMinHeight =
        screenHeight - pokemonInfoBox.size.height + _pokemonSlideOverflow;
    _cardMaxHeight = screenHeight - appBarHeight;

    _cardHeightController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return PokemonCardController(
      controller: _cardController,
      child: Scaffold(
        body: Stack(
          children: <Widget>[
            StreamBuilder(
              stream: _pokemonBloc.currentPokemonStream,
              builder: (_, snapshot) {
                if (!snapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }

                final pokemon = snapshot.data;

                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  color: pokemon.color,
                );
              },
            ),
            AnimatedBuilder(
              animation: _cardHeightController,
              child: PokemonTabInfo(),
              builder: (context, child) {
                return SlidingUpPanel(
                  controller: _cardController,
                  minHeight: _cardMinHeight * _cardHeightController.value,
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
            ),
          ],
        ),
      ),
    );
  }
}

class PokemonCardController extends InheritedWidget {
  const PokemonCardController({
    Key key,
    @required this.controller,
    @required Widget child,
  })  : assert(controller != null),
        assert(child != null),
        super(key: key, child: child);

  final AnimationController controller;

  static PokemonCardController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<PokemonCardController>();
  }

  @override
  bool updateShouldNotify(PokemonCardController old) =>
      controller != old.controller;
}
