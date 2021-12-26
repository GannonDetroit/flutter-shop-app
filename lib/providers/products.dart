//you need to use a mixin, via the with keyword, it's like extending another class but the difference is you merge some properties and aspect into your current class but you don't make it
//full instance (since you can only inherit from one class at a time), so mixins kinda allow you to inherit from more than one class at time.

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
//http only throws its own errors for get and post, so if you do delete, put, or patch you need to do your own error handling

import 'package:shop_app/models/http_exception.dart';
import 'dart:convert';
import '../models/http_exception.dart';
import './product.dart';

//changenotifier allows us to establish behind the scenes communication tunnels in flutter with help from context widget.
class Products with ChangeNotifier {
  List<Product> _items = [];
  final String authToken;
  final String userId;

  Products(
    this.authToken,
    this.userId,
    this._items,
  );

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

  Future<void> updateProduct(String id, Product newProduct) async {
    final productIndex = _items.indexWhere((product) => product.id == id);
    if (productIndex >= 0) {
      final url = Uri.parse(
          'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      //.pathc will only update new info, and retain any old stuff (unlike .put that rewrites the data). so even though i'm missing isFavorite and id, they won't be overwriten in anyway.
      http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price
          }));
      _items[productIndex] = newProduct;
      notifyListeners();
    } else {
      //this check shouldn't be required, i'm doing it more for demo purposes
      print('...');
    }
  }

//this is an example of optimistic updating, it ensures that you re-add/rollback the product if this fails.
  Future<void> deleteProduct(String id) async {
    final url = Uri.parse(
        'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    //store a pointer referene to the product about to be deleted
    var existingProduct = _items[existingProductIndex];
    //remove from local state first
    //this will remove the item from the list, but NOT from memory.
    _items.removeAt(existingProductIndex);
    notifyListeners();
    //this will remove it from the database, but if there is an error it will restore it.
    final res = await http.delete(url);
    //make sure I handle errors that are status code 400+ //tested this by removing .json from url.
    if (res.statusCode >= 400) {
      //rollback data on local state.
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      //throw allows the code to continue to run despite an error.
      throw HttpException('Could Not Delete Product');
    }
    //remove the memory reference to clean it up.
    existingProduct = null;
  }

//using async and await as the example method, promises are used in addProduct.
// [ ] allow for optional positional args and give it a default value. I can choose if I want to filterByUser or not. (not for the whole shop, yes for managing user products).
  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    //if i'm filtering add the filter logic to the URI, otherwise just leave the end empty.
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    final url = Uri.parse(
        //firebase gives you this url, but you need to add ?auth=token to the end if its a protected endpoint (which it should be).
        //for other API's you might need to add the auth token as a header instead of in the URL which is easy with http.get(url, headers: {token: 'abc'})
        'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      //we know the values are maps but I can't do <String, Map> so use dynamic datatype instead.
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      if (extractedData == null) {
        return; //return nothing, avoids a bug for when you have no products.
      }
      //need to fetch the list of data thats the users favorited products
      final urlFav = Uri.parse(
          'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse = await http.get(urlFav);
      final favData = json.decode(favoriteResponse.body);

      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            price: prodData['price'],
            description: prodData['description'],
            imageUrl: prodData['imageUrl'],
            //check if the use has never favorited anything to make this false to avoid a bug,
            //also check to make sure the prodId isn't null by using the ??, which is a operator to check if something is null or not and if null does x if not does y.
            isFavorite: favData == null ? false : favData[prodId] ?? false));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      throw (err);
    }
  }

//making ths into a Future datatype instead of void (even though i'm still resolving to void) so I can set up loading indicators.
//i'll normally use async and await but I want to keep this as an example of using Futures and .thens (essentially Promises from JS).
  Future<void> addProduct(Product product) {
    //because HTTP request take some time to finish, you want to consider if you want to update the server first with the http request or update local/app state first or not.
    //remember that flutter in non-blocking so the code will keep going while you wait for the http request to resolve. here, I will use .then  to make sure the database updates before letting local state update.
    //in firebase only, you can paste in the given uri for your database and just add whatever you want after the '/' like products in this case to create a collection (aka a folder) automatically.

    //remember that flutter runs ALL the code in this file first, and only then goes back to check on the results of Futures aka async code and then runs that stuff/the .thens
    final url = Uri.parse(
        'https://flutter-shop-app-10a51-default-rtdb.firebaseio.com/products.json?auth=$authToken');
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
        'creatorId': userId
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
      //.catchError to do error handling, make sure its always and the end of your .then statements to help avoid bugs
      //.then statements are skipped when an error is thrown.
    }).catchError((error) {
      // print(error);
      throw error;
    });
  }
}
