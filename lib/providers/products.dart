//you need to use a mixin, via the with keyword, it's like extending another class but the difference is you merge some properties and aspect into your current class but you don't make it
//full instance (since you can only inherit from one class at a time), so mixins kinda allow you to inherit from more than one class at time.
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'product.dart';

//changenotifier allows us to establish behind the scenes communication tunnels in flutter with help from context widget.
class Products with ChangeNotifier {
  List<Product> _items = [
    Product(
      id: 'p1',
      title: 'Red Shirt',
      description: 'A red shirt - it is pretty red!',
      price: 29.99,
      imageUrl:
          'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    ),
    Product(
      id: 'p2',
      title: 'Trousers',
      description: 'A nice pair of trousers.',
      price: 59.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    ),
    Product(
      id: 'p3',
      title: 'Yellow Scarf',
      description: 'Warm and cozy - exactly what you need for the winter.',
      price: 19.99,
      imageUrl:
          'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    ),
    Product(
      id: 'p4',
      title: 'A Pan',
      description: 'Prepare any meal you want.',
      price: 49.99,
      imageUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    ),
  ];

//creating this getter because I dont want _items to be accessible outside of this class (which is why I gave it an _) by cloning a copy with ... and returning that
//this non-underscored version of items means I won't hit some harsh bugs by attemping to change _items from outsider of this class, which won't have notifyListeners() correctly wired up (because its only accessible in this class thanks to the mixin).
//failing to do things this way can prevent my widgets from rebuiding the actual latest data in _items.
  // var _showFavoritesOnly = false;
  List<Product> get items {
    // if (_showFavoritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavorite).toList();
    // } else {
    // }
    return [..._items];
  }

  List<Product> get favItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  //do any 'logic' like finding, adding, deleting, etc in here instead of in widgets so its centralized, easy to find, and avoids writing repeat code.
  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  //Keep this an example of way to apply filters in an app-wide way, but in most cases you'll most likely just want to filter this in a specific widgets to avoid bugs.
  // void showFavoritesOnly() {
  //   _showFavoritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavoritesOnly = false;
  //   notifyListeners();
  // }

  void updateProduct(String id, Product newProduct) {
    final productIndex = _items.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      //this check shouldn't be required, i'm doing it more for demo purposes
      print('...');
    }
  }

  void deleteProduct(String id) {
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }

//making ths into a Future datatype instead of void (even though i'm still resolving to void) so I can set up loading indicators.
  Future<void> addProduct(Product product) {
    //because HTTP request take some time to finish, you want to consider if you want to update the server first with the http request or update local/app state first or not.
    //remember that flutter in non-blocking so the code will keep going while you wait for the http request to resolve. here, I will use .then  to make sure the database updates before letting local state update.
    //in firebase only, you can paste in the given uri for your database and just add whatever you want after the '/' like products in this case to create a collection (aka a folder) automatically.

    //remember that flutter runs ALL the code in this file first, and only then goes back to check on the results of Futures aka async code and then runs that stuff/the .thens
    final url = Uri.parse(
        'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/products.json');
    //json.encode can't convert product striaght into json, so we need to make it a bit more explicit as map aka object so it does so correctly.
    return http
        .post(
      url,
      //don't do ID because firebase or your backend should be generating a unique ID for you which is how you will keep things in sync.
      body: json.encode({
        'title': product.title,
        'description': product.description,
        'imageUrl': product.imageUrl,
        'price': product.price,
        'isFavorite': product.isFavorite
      }),
    )
        //this response from firebase holds a key, that it auto generates, that we get to use as a unqiue ID.
        .then((response) {
      //print(json.decode(response.body));
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name']);
      _items.add(newProduct);
      // _items.insert(0, newProduct);//if I wanted to add it to the beginning of the list instead of the end.
      notifyListeners();
    });
  }
}
