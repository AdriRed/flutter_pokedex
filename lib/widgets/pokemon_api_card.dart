import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/apimodels/Pokemon.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';
import 'package:pokedex/consumers/PokemonLoader.dart';

String _formattedPokeIndex(int index) {
  return "#${((index + 1) / 100).toStringAsFixed(2).replaceAll(".", "")}";
}

String capitalizeFirstChar(String text) {
  if (text == null || text.length <= 1) {
    return text.toUpperCase();
  }

  return text[0].toUpperCase() + text.substring(1);
}

class PokemonApiCard extends StatefulWidget {
  final int index;
  final Function onPress;
  final ApiConsumer<PokemonSpecies> pokemon;

  PokemonApiCard(
    this.pokemon, {
    @required this.index,
    Key key,
    this.onPress,
  }) : super(key: key);

  @override
  _PokemonApiCardState createState() =>
      _PokemonApiCardState(this.pokemon, this.index, onPress);
}

class _PokemonApiCardState extends State<PokemonApiCard> {
  _PokemonApiCardState(
      ApiConsumer<PokemonSpecies> consumer, this.index, this.onPress) {
    _consumer = consumer;
  }

  final int index;
  final Function onPress;
  ApiConsumer<PokemonSpecies> _consumer;

  PokemonSpecies get pokemon {
    if (!_consumer.hasInfo)
      throw new Exception("Accessing PokemonSpecies but not fetched data!");
    return _consumer.info;
  }

  Pokemon defaultVariety() {
    return pokemon.defaultVariety.pokemon.info;
  }

  List<Widget> _buildTypes() {
    final widgetTypes = defaultVariety()
        .types
        .map((type) => type.type.info)
        .map(
          (type) => Hero(
            tag: pokemon.names["es"] + type.id.toString(),
            child: PokemonApiCardType(capitalizeFirstChar(type.names["es"])),
          ),
        )
        .expand((item) => [item, SizedBox(height: 6)]);

    return widgetTypes.take(widgetTypes.length - 1).toList();
  }

  Widget _buildCardContent(bool types) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: pokemon.names["es"],
              child: Material(
                color: Colors.transparent,
                child: Text(
                  pokemon.names["es"],
                  style: TextStyle(
                    fontSize: 14,
                    height: 0.7,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ...(types ? _buildTypes() : []),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildDecorations(double itemHeight) {
    return [
      Positioned(
        bottom: -itemHeight * 0.136,
        right: -itemHeight * 0.034,
        child: Image.asset(
          "assets/images/pokeball.png",
          width: itemHeight * 0.754,
          height: itemHeight * 0.754,
          color: Colors.white.withOpacity(0.14),
        ),
      ),
      Positioned(
        bottom: 8,
        right: 12,
        child: Hero(
          tag: defaultVariety().hdSprite,
          child: CachedNetworkImage(
            imageUrl: defaultVariety().hdSprite,
            placeholder: (ctx, str) => Image.asset(
              "assets/images/8bit-pokeball.png",
              filterQuality: FilterQuality.none,
              fit: BoxFit.contain,
              width: itemHeight * 0.6,
              height: itemHeight * 0.6,
              alignment: Alignment.bottomRight,
            ),
            placeholderFadeInDuration: Duration(milliseconds: 250),
            imageBuilder: (context, imageProvider) => Image(
              image: imageProvider,
              fit: BoxFit.contain,
              width: itemHeight * 0.6,
              height: itemHeight * 0.6,
              alignment: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      Positioned(
        top: 10,
        right: 14,
        child: Text(
          _formattedPokeIndex(this.index + 1),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black.withOpacity(0.12),
          ),
        ),
      ),
    ];
  }

  Widget _buildBox({@required Color backcolor, Widget child}) {
    return Container(
      padding: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: backcolor,
            // blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    // log("Building " + index.toString());

    return LayoutBuilder(
      builder: (context, constrains) {
        final itemHeight = constrains.maxHeight;
        // return _buildBox(backcolor: AppColors.lightGrey);
        return FutureBuilder(
          future: _consumer
              .getInfo()
              .then((x) => x.defaultVariety.pokemon.getInfo())
              .then((x) =>
                  Future.wait(x.types.map((type) => type.type.getInfo()))),
          builder: (ctxData, snapshotData) {
            if (snapshotData.connectionState != ConnectionState.done) {
              return _buildBox(backcolor: AppColors.grey, child: Container());
            }
            Color bcolor =
                AppColors.types[defaultVariety().types.first.type.info.id - 1];
            return _buildBox(
              backcolor: bcolor,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onPress,
                    splashColor: Colors.white10,
                    highlightColor: Colors.white10,
                    child: Stack(
                      children: [
                        _buildCardContent(true),
                        ..._buildDecorations(itemHeight),
                      ],
                    ),
                  ),
                ),
              ),
            );

            // return FutureBuilder(
            //   future: Future.wait(
            //       defaultVariety().types.map((x) => x.type.getInfo())),
            //   builder: (ctxData2, snapshotData2) {
            //     if (snapshotData2.connectionState != ConnectionState.done) {
            //       return _buildBox(
            //         backcolor: Colors.black,
            //         child: ClipRRect(
            //           borderRadius: BorderRadius.circular(15),
            //           child: Material(
            //             color: Colors.transparent,
            //             child: InkWell(
            //               onTap: onPress,
            //               splashColor: Colors.white10,
            //               highlightColor: Colors.white10,
            //               child: Stack(
            //                 children: [
            //                   _buildCardContent(false),
            //                   ..._buildDecorations(itemHeight),
            //                 ],
            //               ),
            //             ),
            //           ),
            //         ),
            //       );
            //     }
            //     Color bcolor = AppColors
            //         .types[defaultVariety().types.first.type.info.id - 1];
            //     log(bcolor.toString());
            //     return _buildBox(
            //       backcolor: bcolor,
            //       child: ClipRRect(
            //         borderRadius: BorderRadius.circular(15),
            //         child: Material(
            //           color: Colors.transparent,
            //           child: InkWell(
            //             onTap: onPress,
            //             splashColor: Colors.white10,
            //             highlightColor: Colors.white10,
            //             child: Stack(
            //               children: [
            //                 _buildCardContent(true),
            //                 ..._buildDecorations(itemHeight),
            //               ],
            //             ),
            //           ),
            //         ),
            //       ),
            //     );
            //   },
            // );
          },
        );
      },
    );
  }
}

class PokemonApiCardType extends StatelessWidget {
  const PokemonApiCardType(this.label, {Key key, this.large = false})
      : super(key: key);

  final String label;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 19 : 12,
          vertical: large ? 6 : 4,
        ),
        decoration: ShapeDecoration(
          shape: StadiumBorder(),
          color: Colors.white.withOpacity(0.2),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: large ? 12 : 8,
            height: 0.8,
            fontWeight: large ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
