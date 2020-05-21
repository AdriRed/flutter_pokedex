import 'dart:developer';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/apimodels/Pokemon.dart';
import 'package:pokedex/apimodels/PokemonBaseType.dart';
import 'package:pokedex/apimodels/PokemonSpecies.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/consumers/ApiConsumer.dart';
import 'package:pokedex/consumers/PokemonLoader.dart';
import 'package:pokedex/models/pokeapi_model.dart';

String _formattedPokeIndex(int index) {
  return "#${((index + 1) / 100).toStringAsFixed(2).replaceAll(".", "")}";
}

String capitalizeFirstChar(String text) {
  if (text == null || text.length <= 1) {
    return text.toUpperCase();
  }

  return text[0].toUpperCase() + text.substring(1);
}

// class PokemonApiCard extends StatefulWidget {
//   final int index;
//   final Function onPress;
//   final ApiConsumer<PokemonSpecies> pokemon;
//   final double heigth;
//   PokemonApiCard(this.pokemon,
//       {@required this.index, Key key, this.onPress, this.heigth})
//       : super(key: key);

//   @override
//   _PokemonApiCardState createState() =>
//       _PokemonApiCardState(this.pokemon, this.index, onPress, this.heigth);
// }
class CustomsApiCard extends StatelessWidget {
// class _PokemonApiCardState extends State<PokemonApiCard> {
  // _PokemonApiCardState(ApiConsumer<PokemonSpecies> consumer, this.index,
  //     this.onPress, this.heigth) {
  //   _consumer = consumer;
  // }
  CustomsApiCard(
      {@required this.index,
      Key key,
      this.onPress,
      this.heigth,
      this.image,
      this.name,
      this.type1,
      this.type2})
      : super(key: key);

  final double heigth;
  final String name;
  final int index;
  final Uint8List image;
  final PokemonBaseType type1;
  final PokemonBaseType type2;
  final Function onPress;
  ApiConsumer<PokemonSpecies> _consumer;

  List<Widget> _buildTypes() {
    return [
      PokemonApiCardType(capitalizeFirstChar(type1.names["es"])),
      SizedBox(
        height: 6,
      ),
      PokemonApiCardType(capitalizeFirstChar(type2.names["es"]))
    ];
  }

  Widget _buildCardContent() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Hero(
              tag: this.name + "custom",
              child: Material(
                color: Colors.transparent,
                child: Text(
                  this.name,
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
            ..._buildTypes(),
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
          tag: "image" + index.toString(),
          child: Image.memory(
            this.image,
            fit: BoxFit.contain,
            width: itemHeight * 0.6,
            height: itemHeight * 0.6,
            alignment: Alignment.bottomRight,
          ),
        ),
      ),
      Positioned(
        top: 10,
        right: 14,
        child: Text(
          _formattedPokeIndex(this.index),
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
            // offset: Offset(0, 8),
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
        var itemHeight = this.heigth ?? constrains.maxHeight;
        // return _buildBox(backcolor: AppColors.lightGrey);
        Color bcolor = AppColors.types[type1.id - 1];
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
                    _buildCardContent(),
                    ..._buildDecorations(itemHeight),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PokemonApiCardType extends StatelessWidget {
  const PokemonApiCardType(this.label,
      {Key key,
      this.large = false,
      this.backcolor = Colors.white,
      this.opacity = 0.2,
      this.textColor = Colors.white})
      : super(key: key);

  final String label;
  final bool large;
  final Color backcolor, textColor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: large ? 19 : 12,
          vertical: large ? 6 : 2,
        ),
        decoration: label == ""
            ? null
            : ShapeDecoration(
                shape: StadiumBorder(),
                color: backcolor.withOpacity(opacity),
              ),
        child: label == ""
            ? Container(height: large ? 12 : 8)
            : Text(
                label,
                style: TextStyle(
                  fontSize: large ? 12 : 8,
                  height: 1.3,
                  fontWeight: large ? FontWeight.bold : FontWeight.normal,
                  color: textColor,
                ),
              ),
      ),
    );
  }
}
