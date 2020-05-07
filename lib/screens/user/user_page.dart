import 'dart:developer';
import 'dart:math' as Math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/account.service.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
import 'package:pokedex/widgets/expanded_section.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);
  static const cardHeightFraction = 1;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage>
    with SingleTickerProviderStateMixin {
  double _cardHeight;

  AnimationController _animationController;
  Animation<double> _animationRadius;

  static const EdgeInsets margins = EdgeInsets.symmetric(horizontal: 28);
  static const double _appBarHorizontalPadding = 28.0;
  static const double _appBarTopPadding = 30.0;
  bool _creating;
  final _formKey = GlobalKey<FormState>();
  String _user, _password, _confirmed;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 5));
    // _animationController.repeat(reverse: true);
    _animationRadius = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 1.0, curve: Curves.linear)));

    _animationController.repeat();

    _cardHeight = 0;
    _creating = false;
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
            "Welcome back Pokémon trainer!",
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

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          _textbox(
              icon: Icons.alternate_email,
              placeholder: "Email",
              onChanged: (txt) => _user = txt),
          SizedBox(
            height: 15,
          ),
          _textbox(
            icon: Icons.vpn_key,
            placeholder: "Password",
            onChanged: (txt) => _password = txt,
            obscureText: true,
          ),
          ExpandedSection(
            expand: _creating,
            child: SizedBox(
              height: 15,
            ),
          ),
          ExpandedSection(
            expand: _creating,
            child: _textbox(
              icon: Icons.vpn_key,
              placeholder: "Repeat password",
              onChanged: (txt) => _confirmed = txt,
              obscureText: true,
            ),
          ),
          SizedBox(
            height: 25,
          ),
          OutlineButton(
            child: Text(
              _creating ? "Create new account" : "Log in",
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            onPressed: () {
              if (_creating)
                _create(_user, _password, _confirmed, context);
              else
                _login(_user, _password, context);
            },
            textTheme: ButtonTextTheme.accent,
            borderSide: BorderSide(
              color: AppColors.blue,
              width: 2,
            ),
          ),
          SizedBox(height: 15),
          _buttonCreateAccount(context),
        ],
      ),
    );
  }

  void _login(String user, String password, BuildContext context) {
    AccountHelper.login(user, password, (data) {
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text("Welcome " + loggedUser + "!"),
      // ));
      SessionModel.of(context)
          .setNewData(data)
          .whenComplete(() => Navigator.of(context).popUntil((x) => x.isFirst));
    }, (reason) {
      _globalKey.currentState.showSnackBar(
        SnackBar(
          content: Text(reason),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () => _globalKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
    });
  }

  void _create(
      String user, String password, String repeated, BuildContext context) {
    AccountHelper.create(user, password, repeated, (data) {
      // Scaffold.of(context).showSnackBar(SnackBar(
      //   content: Text("Welcome " + loggedUser + "!"),
      // ));
      SessionModel.of(context)
          .setNewData(data)
          .whenComplete(() => Navigator.of(context).popUntil((x) => x.isFirst));
    }, (reason) {
      _globalKey.currentState.showSnackBar(
        SnackBar(
          content: Text(reason),
          action: SnackBarAction(
            label: 'Ok',
            onPressed: () => _globalKey.currentState.hideCurrentSnackBar(),
          ),
        ),
      );
    });
  }

  Widget _buttonCreateAccount(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 30,
      ),
      child: RichText(
        textAlign: TextAlign.right,
        text: TextSpan(
          children: [
            TextSpan(
              text:
                  _creating ? "Having an account? " : "Not having an account? ",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
            ),
            TextSpan(
              text: _creating ? "Log in!" : 'Create one!',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w400,
                fontSize: 18,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  this.setState(() => _creating = !_creating);
                },
            ),
          ],
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
    final image = Image.asset(
      "assets/images/pokeball.png",
      color: AppColors.black.withAlpha(20),
      height: screenHeight * 0.06,
    );
    _cardHeight = screenHeight * UserPage.cardHeightFraction;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
          Positioned.fill(
            top: screenHeight * 0.5,
            bottom: screenHeight * 0.01,
            left: screenWidth * 0.01,
            right: screenWidth * 0.01,
            child: Center(
              child: RotationTransition(
                turns: _animationRadius,
                child: Stack(
                  children: <Widget>[
                    Transform.translate(
                      offset: Offset(_radius * Math.cos(2 * Math.pi / 4),
                          _radius * Math.sin(2 * Math.pi / 4)),
                      child: image,
                    ),
                    Transform.translate(
                      offset: Offset(_radius * Math.cos(4 * Math.pi / 4),
                          _radius * Math.sin(4 * Math.pi / 4)),
                      child: image,
                    ),
                    Transform.translate(
                      offset: Offset(_radius * Math.cos(6 * Math.pi / 4),
                          _radius * Math.sin(6 * Math.pi / 4)),
                      child: image,
                    ),
                    Transform.translate(
                      offset: Offset(_radius * Math.cos(8 * Math.pi / 4),
                          _radius * Math.sin(8 * Math.pi / 4)),
                      child: image,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
