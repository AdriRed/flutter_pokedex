import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/models/session.model.dart';
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
            "Your profile",
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

  Widget _profileData(BuildContext context) {
    return Consumer<SessionModel>(
      builder: (context, value, child) {
        return Text(value.data.username);
      },
    );
  }

  Widget _profile(BuildContext context) {
    // SessionModel model = SessionModel.of(context);
    // if (model.hasData) {
    //   return _profileData(context);
    // }
    // return FutureBuilder(
    //   future: AccountHelper.self(
    //       (data) => SessionModel.of(context).setNewData(data), null),
    //   builder: (context2, snapshot) {
    //     if (snapshot.connectionState != ConnectionState.done)
    //       return Expanded(
    //         child: Center(
    //           child: CircularProgressIndicator(),
    //         ),
    //       );
    //     return _profileData(context2);
    //   },
    // );

    return Consumer<SessionModel>(
      builder: (context, model, child) {
        if (!model.hasData) {
          AccountHelper.self((data) => model.setNewData(data),
              (r) => log("Not work " + r.toString()));
          return Expanded(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        return _profileData(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
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
            child: _profile(context),
          ),
        ],
      ),
    );
  }
}
