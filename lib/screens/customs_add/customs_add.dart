import 'dart:developer';
import 'dart:math' as Math;
import 'package:http/http.dart' show get;
import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/pokemon.service.dart';
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
    _textBox.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    PokeapiModel pokeapiModel = PokeapiModel.of(context, listen: true);

    if (!pokeapiModel.hasData || !pokeapiModel.hasTypesData) {
      Future.wait([pokeapiModel.init(), pokeapiModel.initTypes()])
          .then((_) => this.setState(() => _loading = false));
    }

    super.didChangeDependencies();
  }

  FocusNode _textBox;
  @override
  void initState() {
    super.initState();
    _cardHeight = 0;
    _sending = false;
    _loading = !PokeapiModel.of(context).hasData;
    var rng = new Math.Random();
    _poke1 = rng.nextInt(152) + 1;
    _poke2 = rng.nextInt(152) + 1;
    _type1 = 1;
    _type2 = 1;
    _textBox = FocusNode();
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
            "You're creating a Pokémon!",
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
      FocusNode focus,
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
              focusNode: focus,
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
  double _width;

  Widget _form(BuildContext context, double height, double width) {
    return Consumer<PokeapiModel>(
      builder: (context, value, child) {
        return Form(
          key: _formKey,
          child: ListView(children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: Text(
                  "It will be called...",
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
              focus: _textBox,
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
                : _loading
                    ? CircularProgressIndicator()
                    : _pokemonFusion(value, height, width),
            SizedBox(
              height: 35,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 35),
                child: Text(
                  "and which types will be...",
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
            _loading
                ? LinearProgressIndicator()
                : _pokemonTypes(value, height, width),
            SizedBox(
              height: 35,
            ),
            _sending
                ? LinearProgressIndicator()
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.25),
                    child: RaisedButton(
                      child: Text("Create!"),
                      textColor: Colors.white,
                      color: AppColors.blue,
                      onPressed: _createCustom,
                    ),
                  ),
            SizedBox(
              height: 45,
            ),
          ]),
        );
      },
    );
  }

  void _createCustom() async {
    var photo = _appearance == 0 ? _galleryPhoto : _fusionPhoto;
    this.setState(() {
      _sending = true;
    });
    if (photo == null && _appearance == 1) {
      var response = await get("https://images.alexonsager.net/pokemon/fused/" +
          _poke2.toString() +
          "/" +
          _poke2.toString() +
          "." +
          _poke1.toString() +
          ".png");
      photo = response.bodyBytes;
    }

    PokemonHelper.addCustom(_name, photo, _type1, _type2, (c) {
      SessionModel.of(context).addCustom(c);
      Navigator.of(context).pop();
    }, (x) {
      setState(() {
        _sending = false;
      });
      showSnackbar(x);
    });
  }

  int _type1;
  int _type2;

  Widget _pokemonTypes(PokeapiModel value, double height, double width) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          // width: width * 0.24,
          child: _pokemonTypeDropdown(value, _type1, (val) {
            _type1 = val;
          }),
        ),
        SizedBox(width: 30, child: Icon(Icons.remove)),
        Container(
          // width: width * 0.24,
          child: _pokemonTypeDropdown(value, _type2, (val) {
            _type2 = val;
          }),
        ),
      ],
    );
  }

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

  Widget _pokemonTypeDropdown(
      PokeapiModel model, int selectedValue, Function(int val) onchange) {
    return DropdownButton<int>(
      value: selectedValue,
      icon: Icon(Icons.dehaze),
      // icon: Container(),
      iconSize: 24,
      dropdownColor: AppColors.lightGrey,
      elevation: 16,
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      onChanged: (int newValue) {
        setState(() {
          onchange(newValue);
        });
      },
      items: model.pokemonTypes.toList().map((x) => x.info).map((type) {
        return DropdownMenuItem<int>(
          value: type.id,
          // child: Text(
          //   type.names["es"],
          // )
          child: PokemonApiCardType(
            type.names["es"],
            large: true,
            backcolor: AppColors.types[type.id - 1],
            textColor: AppColors.types[type.id - 1].red * 0.299 +
                        AppColors.types[type.id - 1].green * 0.587 +
                        AppColors.types[type.id - 1].blue * 0.114 >
                    186
                ? AppColors.black
                : Colors.white,
            opacity: 1,
          ),
        );
      }).toList(),
    );
  }

  Widget _pokemonFusion(PokeapiModel value, double height, double width) {
    return Column(
      children: <Widget>[
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              _pokemonFusionChooser(context, (id) {
                this.setState(() => _poke1 = id);
              }, value, _poke1, height, width),
              SizedBox(
                width: 25,
                child: Icon(Icons.compare_arrows),
              ),
              _pokemonFusionChooser(context, (id) {
                this.setState(() => _poke2 = id);
              }, value, _poke2, height, width),
            ],
          ),
        ),
        SizedBox(
          height: 10,
        ),
        CachedNetworkImage(
          imageUrl: "https://images.alexonsager.net/pokemon/fused/" +
              _poke2.toString() +
              "/" +
              _poke2.toString() +
              "." +
              _poke1.toString() +
              ".png",
          placeholder: (ctx, str) => Image.asset(
            "assets/images/8bit-pokeball.png",
            filterQuality: FilterQuality.none,
            fit: BoxFit.contain,
            width: height * 0.15,
            height: height * 0.15,
            alignment: Alignment.bottomRight,
          ),
          placeholderFadeInDuration: Duration(milliseconds: 250),
          imageBuilder: (context, imageProvider) => Image(
            image: imageProvider,
            fit: BoxFit.contain,
            width: height * 0.15,
            height: height * 0.15,
            alignment: Alignment.bottomRight,
          ),
        ),
      ],
    );
  }

  Widget _pokemonFusionChooser(BuildContext context, Function(int id) onTap,
      PokeapiModel model, int showingNow, double height, double width) {
    var poke = model.pokemons[showingNow - 1];

    return Container(
      height: width * 0.3,
      width: width * 0.4,
      child: PokemonApiCard(
        poke,
        index: showingNow - 1,
        onPress: () => showDialog<int>(
          context: context,
          builder: (context) =>
              _pokemonFusionDialog(context, model, height, width),
        ).then(
          (value) {
            FocusScope.of(context).requestFocus(new FocusNode());
            value = value ?? -1;
            log(value.toString());
            if (value != -1) onTap(value);
          },
        ),
      ),
    );
  }

  Widget _pokemonFusionDialog(
      BuildContext context, PokeapiModel model, double height, double width) {
    return AlertDialog(
      scrollable: true,
      contentPadding: EdgeInsets.all(10),
      content: Container(
        height: height * 0.9,
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
          itemCount: 151,
          itemBuilder: (context, index) => PokemonApiCard(
            model.pokemons[index],
            index: index,
            onPress: () {
              Navigator.of(context).pop(index);
            },
          ),
        ),
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
            child: _form(context, screenHeight, screenWidth),
          ),
        ],
      ),
    );
  }
}
