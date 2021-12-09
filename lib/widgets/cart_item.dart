import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final String id;
  final String productId;
  final double price;
  final int quantity;
  final String title;
  CartItem({this.id, this.price, this.quantity, this.title, this.productId});

  @override
  Widget build(BuildContext context) {
    //Dismissible allows each item to be swipeable for deletion, handling the animation and other heavy stuff out of the box for me. Needs a key
    return Dismissible(
      key: ValueKey(id),
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false).removeItem(productId);
      },
      direction: DismissDirection
          .endToStart, //makes it only swipable from  left to right.
      //background is what is shown in the background when the item is being swiped away.
      background: Container(
        padding: EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        color: Theme.of(context).errorColor,
        //make this margin match the margin of the card below
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              child: FittedBox(
                  child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text('\$$price'),
              )),
            ),
            title: Text(title),
            subtitle: Text('Total: \$${(price * quantity)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}
