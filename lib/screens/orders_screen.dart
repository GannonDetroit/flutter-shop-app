import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/orders.dart' show Orders;
import '../widgets/app_drawer.dart';
import '../widgets/order_item.dart';

//FutureBuilders are ideal for keeping widgets lean and allowing you to not need to make stateful widgets to handle the _isLoading variable and CircularProgressionIndicator widget
//so you get equal ease in handling, less stateful widgets, and is perfect for widgets that are fetching and updating data. It also gives performance boost by
//making it so you don't need to rebuild the entire widget tree due to a state update just do a loading UI change.

//WARNING: the only 'gotcha' with this method is when you have something in the widget that causes the build method to rerun (typically if this was a stateful widget and manageing
//other pieces of state besides _isLoading) then fetchAndSetOrders would be re-executed since its in the build method, which means your HTTP requests will be re-fired again, so this
//can cause an increase in cost and performance. The counter to this is to have this be a stateful widget (which it usually is if you have this bug) and have an _ordersFuture variable and a
//obtainOrdersFuture method, then return that methods result to where the future is in the body (so the actual code is not in the body and not being reran) and use initState to do this only once.
//vid 258 if you need to reference;
//Example of needed code to make this work here:
/*
class _OrdersScreenState extends State<OrdersScreen>{
  Future _ordersFuture;
  Future _obtainOrders{
    return   Provider.of<Orders>(context, listen: false).fetchandSetOrders();
  }

  @override
  void initState(){
    _ordersFuture = _obtainOrders;
    super.initState();
  }
...
..
.
body: FutureBuilder(
  future: _ordersFuture
)
*/
class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        //FutureBuilder takes a future, listens to it automatically and can return different content based on what is returned.
        //the datasnapshot is of type asyncSnapShot it gives you access to the data, error handling, and connectionState (telling you what the future is currently doing,
        //like if its waiting, aka not resolved yet, or if its resolved and then if you have data or an error)
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchandSetOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (snapshot.error != null) {
                //...
                //do error handling
                return Center(
                  child: Text('an error occured'),
                );
              } else {
                return Consumer<Orders>(
                  //always need these three args even though we don't use the last one here
                  builder: (ctx, orderData, child) => ListView.builder(
                    itemBuilder: (ctx, i) => OrderItem(orderData.orders[i]),
                    itemCount: orderData.orders.length,
                  ),
                );
              }
            }
          },
        ));
  }
}
