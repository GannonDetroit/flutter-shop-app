import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import '../widgets/app_drawer.dart';
import '../widgets/products_grid.dart';
import '../widgets/badge.dart';
import '../providers/cart.dart';
import '../providers/products.dart';

//enums are ways to assign labels to ints
enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showOnlyFavorites = false;
  var _isInit = true;
  var _isLoading = false;

  @override
  // void initState() {
  //   // Provider.of<Products>(context).fetchAndSetProducts(); //as noted before, you have two options to make this work. 1.) use listen:false or use this work around, otherwise you'll throw an error.
  //   //work around option 1.
  //   // Future.delayed(Duration.zero).then((_) {
  //   //   Provider.of<Products>(context).fetchAndSetProducts();
  //   // });
  //   super.initState();
  // }

  //work around option2 that we normally use. do NOT use async await on overrides that are not themselves async await, it will change what they return and screw things up.
  @override
  void didChangeDependencies() {
    if (_isInit) {
      //needs to be inside setstate so the UI changes/updates.
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (Enum selectedValue) {
              setState(() {
                if (selectedValue == FilterOptions.Favorites) {
                  _showOnlyFavorites = true;
                } else {
                  _showOnlyFavorites = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem(
                child: Text('Show All'),
                value: FilterOptions.All,
              )
            ],
          ),
          //childd is the icon button, the reason we do this is so it won't be rebuilt every single time cart changes. if I put iconButton in child: childd it would be less performant.
          Consumer<Cart>(
            builder: (_, cart, childd) => Badge(
              child: childd,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
              icon: Icon(Icons.shopping_cart),
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      //itemBuilder passing build context and shows what widgets should be built, gridDelegate is how the grid should be structured (how many columns, etc), the rest is self-explanatory
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : ProductsGrid(_showOnlyFavorites),
    );
  }
}
