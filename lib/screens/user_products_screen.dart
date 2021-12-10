import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import '../widgets/user_products_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';
  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                //nav to new products screen.
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
          itemBuilder: (_, index) {
            return Column(
              children: [
                UserProductItem(productsData.items[index].title,
                    productsData.items[index].imageUrl),
                Divider()
              ],
            );
          },
          itemCount: productsData.items.length,
        ),
      ),
    );
  }
}
