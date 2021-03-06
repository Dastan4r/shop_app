import 'package:flutter/foundation.dart';
import 'dart:convert';

import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  Future<void> toggleFavoriteStatus(String token) async{
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();

    final url = Uri.parse('https://shop-app-92a50-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$token');

    try {
      final response = await http.patch(url, body: json.encode({
        'isFavorite': isFavorite,
      }));

      if(response.statusCode >= 400) {
          isFavorite = oldStatus;
          notifyListeners();
      }
    } catch (err) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}
