import 'package:flutter/foundation.dart';

//most of the notes that would be revelent to explain this strucute is in products provider.

//class for individual cart item.
class CartItem {
  final String id;
  final String title;
  final int quantity;
  final double price;

  CartItem(
      {@required this.id,
      @required this.title,
      @required this.quantity,
      @required this.price});
}

//class for the cart as a whole.
class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

//always do this to avoid needing to directly mess with _items from outside components.
  Map<String, CartItem> get items {
    return {..._items};
  }

  //getter for cart count, doing the sum of product, not the sum of properties (so I have 2 products and one is quanity of 50, its going to say count is 2 not 52. this is by design choice nothing more.)
  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      //change the quanitity...
      _items.update(
          productId,
          (existingCartItem) => CartItem(
              id: existingCartItem.id,
              title: existingCartItem.title,
              price: existingCartItem.price,
              quantity: existingCartItem.quantity + 1));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
              id: DateTime.now().toString(),
              title: title,
              quantity: 1,
              price: price));
    }
    notifyListeners();
  }
}
