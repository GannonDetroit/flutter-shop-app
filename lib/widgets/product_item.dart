import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<Product>(context);
    //GridTile is a great widget to use inside gridViews, allows a child that can be a pic and has a stack() feature in it to allow you to use footer as a variable for other info.
    //using Consumer instead of Provider.of<Product>(context) is just another way of doing pretty much the same thing, I'm keeping it here as a demo example.
    //however, it has some advantages. with Provider.of, the entire build method is rerun, however in theory if I wanted only a subpart of this widget to rerun I could wrap it
    //in Consumer and be slightly more performant. an example here would be to use Provider.of with listen=false to get all the one-time data to populate this widget and then only wrap the
    //favorite button component below since its the only thing that changes and thus the only thing that needs to be rerendered. See video 199 if you want.
    final cart = Provider.of<Cart>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    return Consumer<Product>(
      builder: (ctx, product, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridTile(
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                      arguments: product.id);
                },
                child: FadeInImage(
                  placeholder:
                      AssetImage('assets/images/edit_product_screen.png'),
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                )),
            //can provide the title and button to each tile.
            footer: GridTileBar(
              backgroundColor: Colors.black87,
              // button to the left
              leading: IconButton(
                icon: Icon(product.isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  product.toggleFavoriteStatus(authData.token, authData.userId);
                },
              ),
              title: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
              //button to the right
              trailing: IconButton(
                icon: Icon(Icons.shopping_cart),
                color: Theme.of(context).colorScheme.secondary,
                onPressed: () {
                  cart.addItem(product.id, product.price, product.title);
                  //if there already a snackbar up (due to a user hyper tapping add), the old snackbar will be hidden before the new one is shown so there is less confusion and no bugs.
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  //using scaffold of.context (or ScaffoldMessenger of.context for snackbars) method to the nearest Scaffold widget/app layout (so this wouldn't work if this widget already was using scaffold since I'd already be in it), in this case its product overview screen
                  //we do this because it allows us to do several things, in this case it will be to show a snack bar.
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                      'Added item to cart!',
                      // textAlign: TextAlign.center,
                    ),
                    duration: Duration(seconds: 2),
                    action: SnackBarAction(
                      label: 'UNDO',
                      onPressed: () {
                        cart.removeSingleItem(product.id);
                      },
                    ),
                  ));
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
