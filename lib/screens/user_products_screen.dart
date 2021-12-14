import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/app_drawer.dart';
import '../providers/products.dart';
import '../widgets/user_products_item.dart';

class UserProductsScreen extends StatelessWidget {
  static const routeName = '/user-products';

//since this is not a stateful widget, you need to add context as a arg for it work via BuildContext;
//remember that async await always returns a future automatically so it makes it easier to use on things that expect futures to be returned, like the onRefresh method.
  Future<void> _refreshProducts(BuildContext context) async {
    await Provider.of<Products>(context, listen: false).fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Products'),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              },
              icon: Icon(Icons.add))
        ],
      ),
      drawer: AppDrawer(),
      //the RefreshIndicator gives us pull to refresh functionality out of the box, with a loading spinner and everything.
      body: RefreshIndicator(
        onRefresh: () => _refreshProducts(context),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListView.builder(
            itemBuilder: (_, index) {
              return Column(
                children: [
                  UserProductItem(
                      productsData.items[index].id,
                      productsData.items[index].title,
                      productsData.items[index].imageUrl),
                  Divider()
                ],
              );
            },
            itemCount: productsData.items.length,
          ),
        ),
      ),
    );
  }
}
