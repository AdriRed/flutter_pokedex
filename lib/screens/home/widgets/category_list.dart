import 'package:flutter/cupertino.dart';
import 'package:pokedex/data/categories.dart';

import '../../../widgets/poke_category_card.dart';

class CategoryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.45,
        crossAxisSpacing: 10,
        mainAxisSpacing: 15,
      ),
      padding: EdgeInsets.only(left: 28, right: 28, bottom: 35),
      itemCount: categories.length,
      itemBuilder: (context, index) => PokeCategoryCard(
        categories[index],
        onPress: () => Navigator.of(context).pushNamed(categories[index].route),
      ),
    );
  }
}
