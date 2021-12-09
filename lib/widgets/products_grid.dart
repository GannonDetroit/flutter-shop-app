import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './product_item.dart';
import '../providers/products.dart';

class ProductsGrid extends StatelessWidget {
  final bool showFavs;
  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) {
    //this provider of context sets up a behind-the-scences-connection to the ProviderNotifier in the main.dart file. This is the listener for when products state is updated. the <products> is VERY important so it knows what Provider to listen to.
    final productsData = Provider.of<Products>(context);
    //access the data we want to touch via our getter which is items.
    final products = showFavs ? productsData.favItems : productsData.items;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        //using the ChangeNotifier to listen to each individual product for changes, like when I favorite one or unfavorite it.
        //this example shows how to use .value which works if you are not using the context for anything (which we are not here).
        //however, using .value is great when used in lists or grids like GridView.builder because it avoids bugs that are similar to when we need keys to stop widgets and data from getting out of wack.
        value: products[index],
        child: ProductItem(
            // products[index].id,
            // products[index].title,
            // products[index].imageUrl,
            ),
      ),
      padding: const EdgeInsets.all(10),
      itemCount: products.length,
    );
  }
}
