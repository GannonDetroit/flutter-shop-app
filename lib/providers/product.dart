import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//http only throws its own errors for get and post, so if you do delete, put, or patch you need to do your own error handling

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {@required this.id,
      @required this.title,
      @required this.description,
      @required this.price,
      @required this.imageUrl,
      this.isFavorite = false});

//how i'm rolling back changes if there is an error because this is optimisitc updating style.
  void _setFavValue(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String token) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners(); //this is the equalivent of using setState, make sure you use it whenever your changing the state of the app, but know it only works in the ChangeNotifier is on
    final url = Uri.parse(
        'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/products/$id.json?auth=$token');

    try {
      final res = await http.patch(url,
          body: json.encode({
            'isFavorite': isFavorite,
          }));
      if (res.statusCode >= 400) {
        _setFavValue(oldStatus);
      }
    } catch (err) {
      _setFavValue(oldStatus);
    }
  }
}
