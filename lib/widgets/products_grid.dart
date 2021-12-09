import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import './product_item.dart';
import '../providers/products_provider.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //this provider of context sets up a behind-the-scences-connection to the ProviderNotifier in the main.dart file. This is the listener for when products state is updated. the <products> is VERY important so it knows what Provider to listen to.
    final productsData = Provider.of<Products>(context);
    //access the data we want to touch via our getter which is items.
    final products = productsData.items;

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (ctx, index) => ChangeNotifierProvider(
        //using the ChangeNotifier to listen to each individual product for changes, like when I favorite one or unfavorite it.
        create: (ctx) => products[index],
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
