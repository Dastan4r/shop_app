import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/http_exeption.dart';
import './product.dart';

class Products with ChangeNotifier {
  String? authToken;

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void update(String? token) {
    if (token != null) {
      authToken = token;
      notifyListeners();
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((element) => element.id == id);

    if (prodIndex >= 0) {
      final url = Uri.parse(
        'https://shop-app-92a50-default-rtdb.asia-southeast1.firebasedatabase.app/products/$id.json?auth=$authToken',
      );

      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'price': newProduct.price,
              'imageUrl': newProduct.imageUrl,
            }));
      } catch (err) {
        print(err);
      }

      _items[prodIndex] = newProduct;

      notifyListeners();
    }
  }

  Future<void> getProducts() async {
    final url = Uri.parse(
      'https://shop-app-92a50-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken',
    );

    try {
      final response = await http.get(url);
      final extractedData = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavorite'],
          ),
        );
      });

      _items = loadedProducts;

      notifyListeners();
    } catch (error) {
      print(error);
    }
  }

  Future<void> addProduct(Product product) async {
    final url = Uri.parse(
        'https://shop-app-92a50-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');
    try {
      final response = await http.post(url,
          body: json.encode(
            {
              "description": product.description,
              "title": product.title,
              "price": product.price,
              "imageUrl": product.imageUrl,
              "isFavorite": product.isFavorite,
            },
          ));

      final newProduct = Product(
        description: product.description,
        title: product.title,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(response.body)["name"],
      );

      _items.add(newProduct);

      notifyListeners();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  Future<void> removeProduct(String productId) async {
    final url = Uri.parse(
        'https://shop-app-92a50-default-rtdb.asia-southeast1.firebasedatabase.app/products.json?auth=$authToken');

    final existingProductIndex =
        _items.indexWhere((element) => element.id == productId);
    Product? existingProduct = _items[existingProductIndex];

    try {
      await http
          .delete(url)
          .then((response) => {
                if (response.statusCode >= 400)
                  {throw HttpExeption(message: 'Could not delete product')},
                existingProduct = null
              })
          .catchError((_) {
        _items.insert(existingProductIndex, existingProduct!);
      });
    } catch (err) {
      print(err);
    }

    _items.removeAt(existingProductIndex);

    notifyListeners();
  }
}
