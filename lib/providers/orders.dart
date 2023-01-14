import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem(
      {required this.id,
      required this.amount,
      required this.products,
      required this.dateTime});
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String authToken;
  final String userId;

  Orders(this.authToken,this.userId, this._orders);

  List<OrderItem> get orders {
    return [..._orders];
  }

  List<CartItem> fillLoadedCartItems(List<dynamic> details) {
    List<CartItem> loadedCartItems = [];
    details.forEach((valueProd) {
      loadedCartItems.add(CartItem(
          id: (valueProd as Map<String, dynamic>)['id'],
          title: valueProd['product-name'],
          quantity: valueProd['quantity'],
          price: valueProd['price']));
    });
    return loadedCartItems;
  }

  Future<void> fetchAndSetOrders() async {
    final url = Uri.parse(
        'Firebase URL/orders.json?auth=$authToken&orderBy="ordererId"&equalTo="$userId"');
    try {
      final response = await http.get(url);
      final extractedOrders =
          json.decode(response.body) as Map<String, dynamic>;
      final List<OrderItem> loadedOrders = [];
      extractedOrders.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            amount: orderData['amount'],
            products: fillLoadedCartItems(orderData['products']),
            dateTime: DateTime.parse(orderData['date']),
          ),
        );
      });
      _orders = loadedOrders;
      notifyListeners();
    } catch (error) {
      return Future.error(error);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'Firebase URL/orders.json?auth=$authToken');
    List<Map<String, Object>> items = cartProducts
        .map((cartItem) => {
              'id': cartItem.id,
              'product-name': cartItem.title,
              'quantity': cartItem.quantity,
              'price': cartItem.price
            })
        .toList();
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'ordererId' : userId,
          'amount': total,
          'date': DateTime.now().toIso8601String(),
          'products': items
        }),
      );
      _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'],
            amount: total,
            dateTime: DateTime.now(),
            products: cartProducts),
      );
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }
}
