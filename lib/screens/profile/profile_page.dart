import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pokedex/configs/AppColors.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/screens/pokeapi_info/widgets/decoration_box.dart';
import 'package:pokedex/services/account.service.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({Key key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _editing = false;
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
            (_editing ? "Editing your" : "Your") + " profile",
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

  Widget _profileData(BuildContext context, SessionModel model) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.only(
        left: 30.0,
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  "Photo",
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              model.data.photo == null
                  ? Container(
                      height: 128,
                      width: 128,
                      child: Center(
                        child: Icon(Icons.cancel),
                      ),
                      decoration: BoxDecoration(color: Colors.grey),
                    )
                  : Image.memory(
                      new Uint8List.fromList(base64Decode(model.data.photo)),
                      height: 128,
                    )
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  "Email",
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                model.data.email,
                style: TextStyle(
                  fontSize: 18,
                  height: 0.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              Container(
                width: 100,
                child: Text(
                  "Username",
                  style: TextStyle(
                    fontSize: 18,
                    height: 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                model.data.username,
                style: TextStyle(
                  fontSize: 18,
                  height: 0.5,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 20,
          ),
          OutlineButton(
            child: Text(
              "Edit",
              style: TextStyle(
                color: AppColors.blue,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            onPressed: () async {
              setState(() {
                _editing = true;
                _photo = model.data.photo == null
                    ? null
                    : base64Decode(model.data.photo);
                _email = model.data.email;
                _username = model.data.username;
              });
            },
            textTheme: ButtonTextTheme.accent,
            borderSide: BorderSide(
              color: AppColors.blue,
              width: 2,
            ),
          ),
        ],
      ),
    );
  }

  String _username, _email;
  Uint8List _photo;
  bool _editing;

  static const EdgeInsets margins = EdgeInsets.symmetric(horizontal: 28);
  final _formKey = GlobalKey<FormState>();

  Widget _textbox(
      {IconData icon = Icons.text_fields,
      String placeholder = "",
      String initialValue = "",
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
              initialValue: initialValue,
              validator: validator,
              onChanged: onChanged,
              obscureText: obscureText,
            ),
          ),
        ],
      ),
    );
  }

  String _newPassword = "";
  String _repeatPassword = "";

  Widget _passwordForm(BuildContext context) {
    return AlertDialog(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _textbox(
            icon: Icons.vpn_key,
            placeholder: "New Password",
            onChanged: (txt) => _newPassword = txt,
            obscureText: true,
          ),
          SizedBox(
            height: 15,
          ),
          _textbox(
            icon: Icons.repeat,
            placeholder: "Repeat new password",
            onChanged: (txt) => _repeatPassword = txt,
            obscureText: true,
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OutlineButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _repeatPassword = "";
                    _newPassword = "";
                  });
                  Navigator.of(context).pop();
                },
                textTheme: ButtonTextTheme.accent,
                borderSide: BorderSide(
                  color: AppColors.blue,
                  width: 2,
                ),
              ),
              RaisedButton(
                child: Text(
                  "Change password",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  String newP = _newPassword;
                  String repeatP = _repeatPassword;

                  setState(() {
                    _repeatPassword = "";
                    _newPassword = "";
                  });
                  AccountHelper.changePassword(newP, repeatP, (data) {
                    Navigator.of(context).pop();
                    showSnackbar("Changed password!");
                  }, (err) {
                    Navigator.of(context).pop();
                    showSnackbar(err);
                  });
                },
                textTheme: ButtonTextTheme.accent,
                color: Colors.red,
              ),
            ],
          )
        ],
      ),
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

  Widget _form(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  _photo == null
                      ? Container(
                          height: 128,
                          width: 128,
                          child: Center(
                            child: Icon(Icons.cancel),
                          ),
                          decoration: BoxDecoration(color: Colors.grey),
                        )
                      : Image.memory(
                          new Uint8List.fromList(_photo),
                          height: 128,
                        ),
                  SizedBox(
                    height: 15,
                  ),
                  OutlineButton(
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

                      setState(() {
                        _photo = image.readAsBytesSync();
                      });
                    },
                    textTheme: ButtonTextTheme.accent,
                    borderSide: BorderSide(
                      color: AppColors.blue,
                      width: 2,
                    ),
                  ),
                ],
              ),
              RaisedButton(
                child: Text("Change password"),
                color: AppColors.red,
                textColor: Colors.white,
                onPressed: () {
                  showDialog(
                      context: context,
                      builder: (context) => _passwordForm(context));
                },
              )
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 35),
              child: Text(
                "Username",
                style: TextStyle(
                  fontSize: 18,
                  height: 0.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          _textbox(
              icon: Icons.person_pin,
              initialValue: _username,
              placeholder: "Email",
              onChanged: (txt) => _username = txt),
          SizedBox(
            height: 15,
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 35),
              child: Text(
                "Email",
                style: TextStyle(
                  fontSize: 18,
                  height: 0.5,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 8,
          ),
          _textbox(
            icon: Icons.alternate_email,
            initialValue: _email,
            placeholder: "Email",
            onChanged: (txt) => _email = txt,
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              OutlineButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onPressed: () => this.setState(() {
                  _editing = false;
                }),
                textTheme: ButtonTextTheme.accent,
                borderSide: BorderSide(
                  color: AppColors.blue,
                  width: 2,
                ),
              ),
              RaisedButton(
                child: Text(
                  "Save",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                onPressed: _edit,
                textTheme: ButtonTextTheme.accent,
                color: AppColors.blue,
              ),
            ],
          )
        ],
      ),
    );
  }

  void _edit() {
    UserData newU = UserData(
        username: _username, email: _email, photo: base64Encode(_photo));
    AccountHelper.edit(
      newU,
      (data) {
        SessionModel.of(this.context).setNewData(data);
        this.setState(() {
          _editing = false;
        });
        showSnackbar("Saved!");
      },
      (err) => showSnackbar(err),
    );
  }

  Widget _profile(BuildContext context) {
    return Consumer<SessionModel>(
      builder: (context, model, child) {
        if (!model.hasData) {
          AccountHelper.self(
              (data) => model.setNewData(data), (r) => log(r.toString()));
          return Center(
            child: CircularProgressIndicator(),
          );
        }
        return _profileData(context, model);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
            top: screenHeight * 0.20,
            child: _editing ? _form(context) : _profile(context),
          ),
        ],
      ),
    );
  }
}
