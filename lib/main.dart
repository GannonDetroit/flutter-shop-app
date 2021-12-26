import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import './screens/product_detail_screen.dart';
import './screens/products_overview_screen.dart';
import './screens/orders_screen.dart';
import './screens/cart_screen.dart';
import './screens/user_products_screen.dart';
import './screens/edit_product_screen.dart';
import 'screens/auth_screen.dart';
import './providers/products.dart';
import './providers/cart.dart';
import './providers/orders.dart';
import './providers/auth.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//this ChangeNotifier listens for changes in Products provider, and any child widgets in the app that have a listener set up to this, ONLY those listening will get rebuilt when state in products is changed.
//this could have been done with the .value and swapping create with value, since I don't actually use the context here, but I kept it as is for demo purposes.
    return MultiProvider(
        providers: [
          //just for demo purposes i'm using the .value version for auth. but I could have done the other way too.
          ChangeNotifierProvider.value(value: Auth()),
          //using ProxyProvider because I need to pass the authToken as a arg into Products and we can't do that with just normal provider.
          //ProxyProvide works by relying on a provider that is set up BEFORE this one, so order matters, Auth needs to be above this.
          ChangeNotifierProxyProvider<Auth, Products>(
            //need this create method to initialize things even though nothing is being passed, the update will fill it with the needed info.
            create: (ctx) => Products('', '', []),
            //getting auth from Auth provider and getting previousProducts from Products provider _items essentially.
            update: (ctx, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider(create: (ctx) => Cart()),
          ChangeNotifierProxyProvider<Auth, Orders>(
            create: (ctx) => Orders('', []),
            update: (ctx, auth, previousOrders) => Orders(auth.token,
                previousOrders == null ? [] : previousOrders.orders),
          )
        ],
        //adding consumer for auth on the entire app allows me to rebuild the app based on if someone is logged in or not, this is better than defaulting to login page because then
        //user would need to re-login ALL THE DAMN TIME when the app restarts. This way we can avoid some of that by storing the auth token locally. So this method allows me to have the
        //default home route be dynamically decided.
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'MyShop',
            theme: ThemeData(
                primarySwatch: Colors.purple,
                fontFamily: 'Lato',
                colorScheme:
                    ColorScheme.fromSwatch(primarySwatch: Colors.purple)
                        .copyWith(secondary: Colors.deepOrange)),
            home: auth.isAuth ? ProductsOverviewScreen() : AuthScreen(),
            routes: {
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
              // ProductsOverviewScreen.routeName: (ctx) => ProductsOverviewScreen(),
            },
            debugShowCheckedModeBanner: false,
          ),
        ));
  }
}
