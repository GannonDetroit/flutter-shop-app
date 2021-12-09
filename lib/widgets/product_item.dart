import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/product_detail_screen.dart';
import '../providers/product.dart';

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
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
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
                  product.toggleFavoriteStatus();
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
                onPressed: () {},
              ),
            ),
          ),
        );
      },
    );
  }
}
