import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  //static route name
  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments
        as String; //gives me the id from the namedRoute in product_item args.

    //using the ID from naviagation we can then access any and all info we want on that product via the provider.
    //in this case, I want to set the listen from its default of true to false because I only want it to listen once when this is built. since
    //nothing in this screen is worried about being updated or changed after that fact, its just wasteful to have this thing listening after its been built.
    //TL:DR, I want to get info once from global data store, and not interested in instant update, then don't listen.
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);

    return Scaffold(
      appBar: AppBar(
        title: Text(loadedProduct.title),
      ),
    );
  }
}
