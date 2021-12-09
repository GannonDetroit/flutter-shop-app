import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//importing only Cart because we don't need the CartItem class in providers, which since we us another class also called CartItem in the cart_item widget, helps avoid errors and confusion.
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: EdgeInsets.all(15),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  //spacer takes all aviable space and allows me to push total to the left and chip + order now button to the right.
                  Spacer(),

                  Chip(
                    label: Text(
                      '\$${cart.totalAmount}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('ORDER NOW'),
                    style: TextButton.styleFrom(
                        primary: Theme.of(context).colorScheme.primary),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          //using expanded to take availabe space but not allowing ListView to take infinate space, avoids that bug.
          Expanded(
            child: ListView.builder(
              itemBuilder: (ctx, i) => CartItem(
                  //cart.items is a map (object) but this builder needs to pull info from lists, so add .value.toList() to avoid an bug/error due to data typing.
                  id: cart.items.values.toList()[i].id,
                  title: cart.items.values.toList()[i].title,
                  quantity: cart.items.values.toList()[i].quantity,
                  price: cart.items.values.toList()[i].price),
              itemCount: cart.itemCount,
            ),
          )
        ],
      ),
    );
  }
}
