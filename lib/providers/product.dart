import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});


  Future<void> toggleFavoriteStatus(String token, String userId) async {
    final url = Uri.parse(
        'https://shop-app-2f246-default-rtdb.europe-west1.firebasedatabase.app/userFavorites/$userId/$id.json?auth=$token');
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        throw HttpException('Something went wrong');
      }
    } catch (error) {
      isFavorite = !isFavorite;
      notifyListeners();
      throw error;
    }
    ;
    notifyListeners();
  }
}
