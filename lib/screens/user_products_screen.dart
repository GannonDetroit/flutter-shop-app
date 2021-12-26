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
    await Provider.of<Products>(context, listen: false)
        .fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);

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
      //FutureBuilder fetch data when this screen first loads (and reloads, even though this specific screen doesn't). then show either the
      //progress indicator or the main page (listen false is critical for _refreshProducts or this will be an infinite loop), then the Consumer will
      //rebuild with the correct/most up to date info.
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) => snapshot.connectionState ==
                ConnectionState.waiting
            ? Center(
                child: CircularProgressIndicator(),
              )
            //the RefreshIndicator gives us pull to refresh functionality out of the box, with a loading spinner and everything.
            : RefreshIndicator(
                onRefresh: () => _refreshProducts(context),
                child: Consumer<Products>(
                  builder: (ctx, productsData, _) => Padding(
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
              ),
      ),
    );
  }
}
