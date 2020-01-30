import 'package:get_it/get_it.dart';
import 'package:pokedex/navigations/navigation.dart';

GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => AppNavigation());
}
