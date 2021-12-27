import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/products.dart';

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
      body: CustomScrollView(
        //slivers are parts on the screen that are scrollable.
        slivers: <Widget>[
          SliverAppBar(
            //height it should have when its not the appbar but the image instead.
            expandedHeight: 300,
            //appbar will always be visible
            pinned: true,
            //what should be inside the appbar/how it will change
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          //the list of widgets
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedProduct.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                width: double.infinity,
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                )),
            //just so I can see/test the scroll animation.
            SizedBox(
              height: 800,
            )
          ]))
        ],
      ),
    );
  }
}
