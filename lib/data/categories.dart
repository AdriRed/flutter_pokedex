import '../configs/AppColors.dart';
import '../models/category.dart';

const List<Category> categories = [
  Category(name: "Pokedex", color: AppColors.teal, route: "/pokedex"),
  Category(name: "Pokedex API", color: AppColors.indigo, route: "/pokedex-api"),
  Category(name: "Moves", color: AppColors.red, route: "/pokedex"),
  Category(name: "Abilities", color: AppColors.blue, route: "/pokedex"),
  Category(name: "Items", color: AppColors.yellow, route: "/pokedex"),
  Category(name: "Locations", color: AppColors.purple, route: "/pokedex"),
  Category(name: "Type Charts", color: AppColors.brown, route: "/pokedex"),
];
