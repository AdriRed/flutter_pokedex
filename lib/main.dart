import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pokedex/models/pokeapi_model.dart';
import 'package:pokedex/models/pokemon.dart';
import 'package:pokedex/models/session.model.dart';
import 'package:pokedex/screens/pokeapi_info/pokeapi_info.dart';
import 'package:pokedex/screens/pokedex_api/pokedex_api.dart';
import 'package:pokedex/screens/profile/profile_page.dart';
import 'package:pokedex/screens/login/login_page.dart';
import 'package:provider/provider.dart';

import 'configs/AppColors.dart';
import 'screens/home/home.dart';
import 'widgets/fade_page_route.dart';

void main() => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => PokemonModel()),
          ChangeNotifierProvider(
            create: (context) => PokeapiModel(),
          ),
          ChangeNotifierProvider(
            create: (context) => SessionModel(),
          )
          // ... other provider(s)
        ],
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  Route _getRoute(RouteSettings settings) {
    switch (settings.name) {
      case "/":
        return FadeRoute(page: Home());

      case '/pokedex-api':
        return FadeRoute(page: PokedexApi());

      case '/pokeapi-info':
        return FadeRoute(page: PokeapiInfo());

      case '/login':
        return FadeRoute(page: LoginPage());

      case '/profile':
        return FadeRoute(page: ProfilePage());

      default:
        return null;
    }
  }

  void preloadAssets(BuildContext context) {
    precacheImage(AssetImage('assets/images/dotted.png'), context);
    precacheImage(AssetImage('assets/images/female.png'), context);
    precacheImage(AssetImage('assets/images/male.png'), context);
    precacheImage(AssetImage('assets/images/pokeball.png'), context);
    precacheImage(AssetImage('assets/images/thumbnail.png'), context);
    precacheImage(AssetImage('assets/images/bulbasaur.png'), context);
    precacheImage(AssetImage('assets/images/charmander.png'), context);
    precacheImage(AssetImage('assets/images/squirtle.png'), context);
  }

  @override
  Widget build(BuildContext context) {
    preloadAssets(context);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      color: Colors.white,
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'CircularStd',
        textTheme:
            Theme.of(context).textTheme.apply(displayColor: AppColors.black),
        scaffoldBackgroundColor: AppColors.lightGrey,
        primarySwatch: Colors.blue,
      ),
      onGenerateRoute: _getRoute,
    );
  }
}
