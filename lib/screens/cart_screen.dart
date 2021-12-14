import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
//importing only Cart because we don't need the CartItem class in providers, which since we us another class also called CartItem in the cart_item widget, helps avoid errors and confusion.
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

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
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              .color),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  OrderButton(cart: cart)
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
                  productId: cart.items.keys.toList()[i],
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

//extracted this button into a seperate widget so I could make ONLY it a stateful widget since I only need state to allow the loading indictator to work and
//I don't want to conver the entire above widget into a stateful one just for that feature. leaving it in this file since it will only be used in this file so
//why waste the time to make it a seperate file even though its techncially a seperate widget.
class OrderButton extends StatefulWidget {
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  var _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      //if there is nothing in the cart, disable the button by having onPressed be null. otherwise allow order function to work.
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading)
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              await Provider.of<Orders>(context, listen: false).addOrder(
                  widget.cart.items.values.toList(), widget.cart.totalAmount);
              widget.cart.clearCart();
              setState(() {
                _isLoading = false;
              });
            },
      child: _isLoading ? CircularProgressIndicator() : Text('ORDER NOW'),
      style:
          TextButton.styleFrom(primary: Theme.of(context).colorScheme.primary),
    );
  }
}
