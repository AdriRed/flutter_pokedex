import '../configs/AppColors.dart';
import '../models/category.dart';

const List<Category> categories = [
  Category(name: "Pokedex", color: AppColors.teal, route: "/pokedex-api"),
  Category(name: "Favourites", color: AppColors.blue, route: "/favourites"),
  Category(name: "Custom", color: AppColors.lightRed, route: "/custom"),
];
