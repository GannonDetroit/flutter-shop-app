//you need to use a mixin, via the with keyword, it's like extending another class but the difference is you merge some properties and aspect into your current class but you don't make it
//full instance (since you can only inherit from one class at a time), so mixins kinda allow you to inherit from more than one class at time.
import 'package:flutter/material.dart';
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
  List<Product> get items {
    return [..._items];
  }

  //do any 'logic' like finding, adding, deleting, etc in here instead of in widgets so its centralized, easy to find, and avoids writing repeat code.
  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  void addProduct() {
    //  _items.add(value);
    notifyListeners();
  }
}
