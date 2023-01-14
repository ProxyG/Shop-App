import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/widgets/app_drawer.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future<void> _refreshOrders(BuildContext context) async {
    await Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    //final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (snapshot.hasError) {
                return RefreshIndicator(
                  onRefresh: () => _refreshOrders(context),
                  child: ListView(children: [
                    Padding(
                      padding: EdgeInsets.only(
                          top: MediaQuery.of(context).size.height / 2.5),
                      child: Center(
                        child: Text(
                          'An error occured!',
                          style: TextStyle(color: Theme.of(context).errorColor),
                        ),
                      ),
                    ),
                  ]),
                );
              } else {
                return RefreshIndicator(
                  onRefresh: () => _refreshOrders(context),
                  child: Consumer<Orders>(
                    builder: (context, orderData, child) => ListView.builder(
                      itemCount: orderData.orders.length,
                      itemBuilder: (context, index) =>
                          OrderItem(orderData.orders[index]),
                    ),
                  ),
                );
              }
            }
          },
        ));
  }
}
