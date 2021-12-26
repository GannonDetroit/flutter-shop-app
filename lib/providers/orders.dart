import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;
  OrderItem(
      {@required this.id,
      @required this.amount,
      @required this.dateTime,
      @required this.products});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;

  Orders(this.authToken, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchandSetOrders() async {
    final url = Uri.parse(
        'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/orders.json?auth=$authToken');

    final res = await http.get(url);
    // if (jsonDecode(res.body) == null) {
    //   return;
    // }

    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(res.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return; //do nothing, avoids a bug for when you have no orders
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          dateTime: DateTime.parse(orderData['dateTime']),
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title']))
              .toList(),
        ),
      );
    });
    //.reversered.toList is to put it order of newest order first.
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    //doing the timeStamp here because putting it in the try block could screw it up by a few miliseconds between the .insert  and the .post
    final timeStamp = DateTime.now();
    final url = Uri.parse(
        'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/orders.json?auth=$authToken');

    final res = await http.post(
      url,
      body: json.encode({
        'amount': total,
        'dateTime': timeStamp.toIso8601String(),
        'products': cartProducts
            .map((cartProd) => {
                  'id': cartProd.id,
                  'title': cartProd.title,
                  'quantity': cartProd.quantity,
                  'price': cartProd.price
                })
            .toList()
      }),
    );

    //using .add puts it at the end of the list, but using .insert with index 0 buts it at the front of the list.
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(res.body)['name'],
            amount: total,
            dateTime: timeStamp,
            products: cartProducts));
    notifyListeners();
  }
}
