import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/helpers/apiHelper.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/screens/customs/widgets/customs_api_card.dart';
import 'package:pokedex/services/account.service.dart';
import 'package:pokedex/services/pokemon.service.dart';
import 'package:pokedex/services/token.handler.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

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
              sessionModel.hasCustomsData &&
              sessionModel.hasUserData);
        });
        Future.wait(
          [
            PokemonHelper.getMyCustom(
                (data) => sessionModel.setCustomsData(data), (x) {
              log("Error loading customs");
              showSnackbar(x);
            }),
            AccountHelper.self((data) => sessionModel.setUserData(data), (x) {
              log("Error loading user");
              showSnackbar(x);
            }),
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
            itemBuilder: (context, index) => GestureDetector(
              onLongPress: () => {
                showDialog(
                  context: context,
                  child: AlertDialog(
                    title:
                        Text("Do you want to delete " + list[index].name + "?"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text(
                          "Nope",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                      FlatButton(
                        child: Text(
                          "A la brossa",
                          style: TextStyle(color: Colors.red),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                    ],
                  ),
                ).then((value) {
                  if (value) {
                    this.setState(() {
                      _loading = true;
                    });
                    PokemonHelper.removeCustom(list[index].id, (favourite) {
                      sessionModel.removeCustom(list[index].id);
                      this.setState(() {
                        _loading = false;
                      });
                    }, (body) {
                      log(body);
                      showSnackbar(body);
                    });
                  }
                })
              },
              child: CustomsApiCard(
                index: list[index].id,
                image: base64Decode(list[index].photo),
                name: list[index].name,
                type1: pokeapiModel.pokemonTypes
                    .firstWhere(
                        (element) => element.info.id == list[index].type1)
                    .info,
                type2: pokeapiModel.pokemonTypes
                    .firstWhere(
                        (element) => element.info.id == list[index].type2)
                    .info,
              ),
            ),
          ),
        );
      },
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

  GlobalKey<ScaffoldState> _globalKey = new GlobalKey();

  Widget _buildPage(BuildContext context, {Widget child, bool action}) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: _globalKey,
      floatingActionButton: !action
          ? null
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                FloatingActionButton(
                    child: Icon(Icons.center_focus_strong),
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    heroTag: "fab-up",
                    onPressed: () {
                      showDialog(
                          context: context,
                          child: AlertDialog(
                            content: Container(
                              width: screenWidth * 0.95,
                              height: screenHeight * 0.95,
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    width: screenWidth * 0.95,
                                    height: screenHeight * 0.80,
                                    child: QRView(
                                      key: qrKey,
                                      onQRViewCreated: (x) => _onQRViewCreated(
                                          x, screenHeight, screenWidth),
                                    ),
                                  ),
                                  RaisedButton.icon(
                                    onPressed: () => controller.toggleFlash(),
                                    icon: Icon(Icons.flash_on),
                                    label: Text("Toggle flash"),
                                  )
                                ],
                              ),
                            ),
                          ));
                    }),
                SizedBox(
                  height: 10,
                ),
                FloatingActionButton(
                  heroTag: "fab-down",
                  child: Icon(Icons.add),
                  onPressed: () {
                    Navigator.of(context).pushNamed("/customs-add");
                  },
                ),
              ],
            ),
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
              SessionModel.of(context).hasUserData
                  ? GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          child: AlertDialog(
                            content: Container(
                              height: 250,
                              width: 600,
                              padding: EdgeInsets.only(left: 15),
                              child: QrImage(
                                data: ApiHelper.apiUrl +
                                    "/api/pokemon/custom/from/" +
                                    SessionModel.of(context)
                                        .userData
                                        .id
                                        .toString(),
                                version: QrVersions.auto,
                                // size: 500,
                                gapless: true,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Icon(Icons.gradient),
                    )
                  : Container(),
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

  bool readed;
  bool subscribed = false;

  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;
  void _onQRViewCreated(
      QRViewController controller, double screenHeight, double screenWidth) {
    this.controller = controller;
    this.setState(() {
      readed = false;
    });
    controller.scannedDataStream.listen(_onReadQr);
    if (!subscribed) {
      this.setState(() {
        subscribed = true;
      });
    }
  }

  void _onReadQr(String barcode) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    if (readed) return;
    this.setState(() {
      readed = true;
    });
    Navigator.of(context).pop();
    log(barcode);
    PokemonHelper.getOthersCustom(barcode, (result) {
      if (result.customs.length == 0) {
        showSnackbar("This user dont have any custom pokemon...");
      } else
        showDialog(
            context: context,
            child: AlertDialog(
              title: Text("Custom pokemon of " + result.customs[0].owner),
              content: Container(
                height: screenHeight * 0.9,
                width: screenWidth * 0.85,
                child: GridView.builder(
                    padding: EdgeInsets.only(left: 0, right: 0, bottom: 58),
                    physics: BouncingScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: result.customs.length,
                    itemBuilder: (context, index) {
                      var selected = result.customs[index];
                      var types = PokeapiModel.of(context).pokemonTypes;
                      return CustomsApiCard(
                          index: selected.id,
                          name: selected.name,
                          image: base64Decode(selected.photo),
                          type1: types
                              .firstWhere((element) =>
                                  element.info.id == selected.type1)
                              .info,
                          type2: types
                              .firstWhere((element) =>
                                  element.info.id == selected.type2)
                              .info);
                    }),
              ),
            ));
    }, (_) => null);
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (this._loading ?? false) {
      return _buildPage(
        context,
        action: false,
        child: Expanded(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return _buildPage(
      context,
      child: _buildList(context),
      action: true,
    );
  }
}
