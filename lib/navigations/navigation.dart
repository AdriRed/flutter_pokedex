import 'package:flutter/widgets.dart';

import '../locator.dart';
import '../screens/home/home.dart';
import '../screens/pokedex/pokedex.dart';
import '../screens/pokemon_info/pokemon_info.dart';
import '../widgets/fade_page_route.dart';

enum Routes { home, pokedex, pokemonInfo }

/// Add more functionality to the enum Routes
extension RoutesExtension on Routes {
  static const Map<Routes, String> routeMap = {
    Routes.home: "/",
    Routes.pokedex: "/pokedex",
    Routes.pokemonInfo: "/pokemon-info",
  };

  String get value => routeMap[this];

  static Routes fromPath(String path) {
    for (final entry in routeMap.entries) {
      if (entry.value == path) {
        return entry.key;
      }
    }

    return Routes.home;
  }
}

class AppNavigation {
  final navigatorKey = GlobalKey<NavigatorState>();

  AppNavigation();
  factory AppNavigation.instance() => locator<AppNavigation>();

  /// Push a named route onto the navigator.
  Future<dynamic> push(Routes route) =>
      navigatorKey.currentState.pushNamed(route.value);

  /// Replace the current route of the navigator by pushing the route
  /// [route] and then disposing the previous route once the new route has
  /// finished animating in.
  Future<dynamic> replace(Routes route) =>
      navigatorKey.currentState.pushReplacementNamed(route.value);

  /// Pop the top-most route off the navigator.
  void pop() => navigatorKey.currentState.pop();

  static Route onGenerateRoute(RouteSettings settings) {
    final route = RoutesExtension.fromPath(settings.name);

    switch (route) {
      case Routes.home:
        return FadeRoute(page: Home());

      case Routes.pokedex:
        return FadeRoute(page: Pokedex());

      case Routes.pokemonInfo:
        return FadeRoute(page: PokemonInfo());

      default:
        return null;
    }
  }
}
