import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
import 'package:pokedex/widgets/expanded_section.dart';

class UserPage extends StatefulWidget {
  UserPage({Key key}) : super(key: key);
  static const cardHeightFraction = 1;

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  double _cardHeight;

  static const EdgeInsets margins = EdgeInsets.symmetric(horizontal: 28);
  static const double _appBarHorizontalPadding = 28.0;
  static const double _appBarTopPadding = 30.0;
  bool _creating;
  final _formKey = GlobalKey<FormState>();
  String _user, _password, _confirmed;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
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
        ),
        SizedBox(
          height: 50,
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
              icon: Icons.person,
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
            onPressed: () => {log("pressed")},
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

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _cardHeight = screenHeight * UserPage.cardHeightFraction;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            child: _buildCard(),
          ),
          Positioned.fill(
            top: screenHeight * 0.30,
            child: _form(context),
          ),
        ],
      ),
    );
  }
}
