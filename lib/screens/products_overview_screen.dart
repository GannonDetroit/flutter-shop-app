import 'package:flutter/material.dart';
import '../widgets/products_grid.dart';

class ProductsOverviewScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
      ),
      //itemBuilder passing build context and shows what widgets should be built, gridDelegate is how the grid should be structured (how many columns, etc), the rest is self-explanatory
      body: ProductsGrid(),
    );
  }
}
