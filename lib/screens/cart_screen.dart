import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart' show Cart;
import '../widgets/cart_item.dart';
import '../providers/orders.dart';

class CartScreen extends StatefulWidget {
  static const routeName = '/cart';
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  var _isOrdering = false;

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Cart'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(15),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color: Theme.of(context)
                              .primaryTextTheme
                              .headline6
                              ?.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  cart.totalAmount > 0
                      ? (_isOrdering
                          ? const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: CircularProgressIndicator(),
                            )
                          : TextButton(
                              onPressed: () async {
                                try {
                                  setState(() {
                                    _isOrdering = true;
                                  });
                                  await Provider.of<Orders>(context,
                                          listen: false)
                                      .addOrder(cart.items.values.toList(),
                                          cart.totalAmount);
                                  setState(() {
                                    _isOrdering = false;
                                  });
                                  scaffoldMessenger.hideCurrentSnackBar();
                                  scaffoldMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Order added successfully!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ),
                                  );
                                  cart.clear();
                                } catch (error) {
                                  scaffoldMessenger.hideCurrentSnackBar();
                                  scaffoldMessenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Order adding failed!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color:
                                                Theme.of(context).errorColor),
                                      ),
                                    ),
                                  );
                                }
                              },
                              child: Text('ORDER NOW'),
                              style: TextButton.styleFrom(
                                  textStyle: TextStyle(
                                      color: Theme.of(context).primaryColor)),
                            ))
                      : const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            'ORDER NOW',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                ],
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
              child: ListView.builder(
            itemBuilder: (context, i) => CartItem(
                cart.items.values.toList()[i].id,
                cart.items.keys.toList()[i],
                cart.items.values.toList()[i].price,
                cart.items.values.toList()[i].quantity,
                cart.items.values.toList()[i].title),
            itemCount: cart.items.length,
          ))
        ],
      ),
    );
  }
}
