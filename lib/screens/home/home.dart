import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/services/account.service.dart';
import 'package:pokedex/services/token.handler.dart';
import 'package:pokedex/widgets/custom/sidebar.dart';
import 'package:pokedex/widgets/custom_poke_container.dart';

import '../../configs/AppColors.dart';
import '../../widgets/poke_container.dart';
import 'widgets/category_list.dart';
import 'widgets/news_list.dart';
import 'widgets/search_bar.dart';

class Home extends StatefulWidget {
  static const cardHeightFraction = 0.71;

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  double _cardHeight;
  ScrollController _scrollController;
  bool _showTitle;
  bool _showToolbarColor;

  static const double _appBarHorizontalPadding = 28.0;
  static const double _appBarTopPadding = 30.0;

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);

    super.dispose();
  }

  @override
  void initState() {
    _cardHeight = 0;
    _showTitle = false;
    _showToolbarColor = false;
    _scrollController = ScrollController()..addListener(_onScroll);

    super.initState();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final showTitle = _scrollController.offset > _cardHeight - kToolbarHeight;

    final showToolbarColor = _scrollController.offset > kToolbarHeight;

    if (showTitle != _showTitle || showToolbarColor != _showToolbarColor) {
      setState(() {
        _showTitle = showTitle;
        _showToolbarColor = showToolbarColor;
      });
    }
  }

  final globalKey = GlobalKey<ScaffoldState>();

  Widget _buildCard(BuildContext context) {
    final model = SessionModel.of(context);
    Future loggedIn = TokenHandler.isLoggedIn;
    loggedIn.then((res) {
      if (res && !model.hasData)
        AccountHelper.self(
            (data) => model.setNewData(data), () => log("error getting self"));
    });

    return CustomPokeContainer(
      appBar: <Widget>[
        FutureBuilder(
          future: loggedIn,
          builder: (ctx, snp) {
            if (snp.hasData && snp.data)
              return InkWell(
                onTap: () {
                  log("logout");
                  TokenHandler.removeToken().then((value) {
                    model.removeData();
                    this.setState(() => 1);
                    globalKey.currentState.showSnackBar(
                      SnackBar(
                        content: Text("Good bye!"),
                        action: SnackBarAction(
                          label: 'Bye!',
                          onPressed: () =>
                              globalKey.currentState.hideCurrentSnackBar(),
                        ),
                      ),
                    );
                  });
                },
                child: Icon(Icons.power_settings_new),
              );
            else
              return Container();
          },
        ),
        Container(),
        model.hasData
            ? InkWell(
                onTap: () => globalKey.currentState.showSnackBar(SnackBar(
                  content: Text("Hello! " + model.data.username),
                  action: SnackBarAction(
                    label: 'Hello Pokedex App!',
                    onPressed: () =>
                        globalKey.currentState.hideCurrentSnackBar(),
                  ),
                )),
                child: Icon(Icons.android),
              )
            : InkWell(
                onTap: () => Navigator.of(context).pushNamed('/user'),
                child: Icon(Icons.person),
              ),
      ],
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
      ),
      children: <Widget>[
        SizedBox(height: 30),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 28),
          child: Text(
            "What Pokemon\nare you looking for?",
            style: TextStyle(
              fontSize: 30,
              height: 0.9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        SizedBox(height: 40),
        SearchBar(),
        SizedBox(height: 42),
        CategoryList(),
      ],
    );
  }

  Widget _buildNews() {
    return ListView(
      physics: BouncingScrollPhysics(),
      children: <Widget>[
        Padding(
          padding:
              const EdgeInsets.only(left: 28, right: 28, top: 0, bottom: 22),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                "Pokémon News",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                "View All",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.indigo,
                ),
              ),
            ],
          ),
        ),
        NewsList(),
      ],
    );
  }

  Widget _buildAppBar({Widget child}) {
    return Padding(
      padding: EdgeInsets.only(
        left: _appBarHorizontalPadding,
        right: _appBarHorizontalPadding,
        top: _appBarTopPadding,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              // InkWell(child: null
              //     // onTap: Navigator.of(context).pop,
              //     ),
              child
            ],
          ),
          // This widget just sit here for easily calculate the new position of
          // the pokemon name when the card scroll up
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    _cardHeight = screenHeight * Home.cardHeightFraction;

    return Scaffold(
      // drawer: SideBar(),
      key: globalKey,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (_, __) => [
          SliverAppBar(
            expandedHeight: _cardHeight,
            floating: true,
            pinned: true,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(30),
              ),
            ),
            backgroundColor: Colors.red,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              centerTitle: true,
              title: _showTitle
                  ? _buildAppBar(
                      child: Text(
                        "Pokedex",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : null,
              background: _buildCard(context),
            ),
          ),
        ],
        body: _buildNews(),
      ),
    );
  }
}
