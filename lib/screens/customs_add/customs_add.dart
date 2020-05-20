import 'dart:math' as Math;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
import 'package:pokedex/widgets/pokemon_api_card.dart';
import 'package:provider/provider.dart';

class CustomsAddPage extends StatefulWidget {
  CustomsAddPage({Key key}) : super(key: key);
  static const cardHeightFraction = 1;

  @override
  _CustomsAddPageState createState() => _CustomsAddPageState();
}

class _CustomsAddPageState extends State<CustomsAddPage>
    with SingleTickerProviderStateMixin {
  double _cardHeight;

  static const EdgeInsets margins = EdgeInsets.symmetric(horizontal: 28);
  static const double _appBarHorizontalPadding = 28.0;
  static const double _appBarTopPadding = 30.0;
  bool _creating, _sending;
  final _formKey = GlobalKey<FormState>();
  int _poke1, _poke2;
  bool _loading;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    PokeapiModel pokeapiModel = PokeapiModel.of(context, listen: true);

    if (!pokeapiModel.hasData) {
      pokeapiModel.init().then((_) => this.setState(() => _loading = false));
    }

    super.didChangeDependencies();
  }

  @override
  void initState() {
    _cardHeight = 0;
    _sending = false;
    _loading = !PokeapiModel.of(context).hasData;
    var rng = new Math.Random();
    _poke1 = rng.nextInt(152) + 1;
    _poke2 = rng.nextInt(152) + 1;

    super.initState();
  }

  Widget _buildCard() {
    return CustomPokeContainer(
      appBar: <Widget>[
        InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Icon(Icons.arrow_back),
        )
      ],
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      children: <Widget>[
        SizedBox(height: 26),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            "Give it some name and appearance",
            style: TextStyle(
              fontSize: 30,
              height: 0.9,
              fontWeight: FontWeight.w900,
            ),
          ),
        )
      ],
    );
  }

  Widget _textbox(
      {IconData icon = Icons.text_fields,
      String placeholder = "",
      Function(String) validator,
      Function(String) onChanged,
      bool obscureText = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18),
      margin: margins,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon),
          SizedBox(width: 13),
          Expanded(
            child: TextFormField(
              decoration: InputDecoration(
                hintText: placeholder,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
              ),
              validator: validator,
              onChanged: onChanged,
              obscureText: obscureText,
            ),
          ),
        ],
      ),
    );
  }

  String _name = "";
  Uint8List _galleryPhoto;
  Uint8List _fusionPhoto;
  int _appearance = 0;

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              "Give it some name",
              style: TextStyle(
                fontSize: 18,
                height: 0.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        _textbox(
          icon: Icons.adb,
          placeholder: "Name",
          onChanged: (txt) => _name = txt,
        ),
        SizedBox(
          height: 35,
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 35),
            child: Text(
              "and its appearance will come from...",
              style: TextStyle(
                fontSize: 18,
                height: 0.5,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Radio(
              value: 0,
              groupValue: _appearance,
              onChanged: (v) {
                if (_appearance != v)
                  setState(() {
                    _appearance = v;
                  });
              },
            ),
            Text(
              "my Gallery",
              style: TextStyle(
                fontSize: 15,
                height: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Radio(
              value: 1,
              groupValue: _appearance,
              onChanged: (v) {
                if (_appearance != v)
                  setState(() {
                    _appearance = v;
                  });
              },
            ),
            Text(
              "a FUSION",
              style: TextStyle(
                fontSize: 15,
                height: 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        _appearance == 0
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _galleryPhoto == null
                      ? Container(
                          height: 128,
                          width: 128,
                          child: Center(
                            child: Icon(Icons.cancel),
                          ),
                          decoration: BoxDecoration(color: Colors.grey),
                        )
                      : Image.memory(
                          new Uint8List.fromList(_galleryPhoto),
                          height: 128,
                        ),
                  Container(
                    // padding: EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                    child: OutlineButton(
                      child: Text(
                        "Change photo",
                        style: TextStyle(
                          color: AppColors.blue,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      onPressed: () async {
                        var image = await ImagePicker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null)
                          setState(() {
                            _galleryPhoto = image.readAsBytesSync();
                          });
                      },
                      textTheme: ButtonTextTheme.accent,
                      borderSide: BorderSide(
                        color: AppColors.blue,
                        width: 2,
                      ),
                    ),
                  )
                ],
              )
            : _loading ? CircularProgressIndicator() : _pokemonFusion()
      ]),
    );
  }

  Widget _pokemonFusion() {
    return Consumer<PokeapiModel>(
      builder: (context, value, child) {
        return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _pokemonFusionChooser((id) => null, value, _poke1),
              SizedBox(
                width: 15,
              ),
              _pokemonFusionChooser((id) => null, value, _poke2),
            ],
          ),
        );
      },
    );
  }

  Widget _pokemonFusionChooser(
      Function(int id) onTap, PokeapiModel model, int showingNow) {
    var poke = model.pokemons[showingNow - 1];
    return Container(
      height: 150,
      width: 150,
      child: PokemonApiCard(
        poke,
        index: showingNow - 1,
        onPress: () => 1,
      ),
    );
  }

  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();
  final _radius = 60.0;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    _cardHeight = screenHeight * CustomsAddPage.cardHeightFraction;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      key: _globalKey,
      body: Stack(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Align(
            alignment: Alignment.topCenter,
            child: _buildCard(),
          ),
          Positioned.fill(
            top: screenHeight * 0.27,
            child: _form(context),
          ),
        ],
      ),
    );
  }
}
