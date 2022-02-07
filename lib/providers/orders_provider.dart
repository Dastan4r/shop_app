import 'package:flutter/foundation.dart';
import 'dart:convert';
import './cart.dart';

import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final double price;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.price,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get getOrders => [..._orders];

  late String authToken;

  void update(String? token) {
    if (token != null) {
      authToken = token;

      notifyListeners();
    }
  }

  Future<void> getAndSetOrders() async {
    final url = Uri.parse(
      'https://shop-app-92a50-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json?auth=$authToken',
    );

    try {
      final response = await http.get(url);

      final List<OrderItem> loadedOrders = [];
      final extractedData = json.decode(response.body) as Map<String, dynamic>;

      extractedData.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            price: orderData['price'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>).map((e) {
              return CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price']);
            }).toList(),
          ),
        );
      });

      _orders = loadedOrders;

      notifyListeners();
    } catch (err) {
      print(err);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse(
        'https://shop-app-92a50-default-rtdb.asia-southeast1.firebasedatabase.app/orders.json?auth=$authToken');
    final timeStamp = DateTime.now();

    try {
      final response = await http.post(url,
          body: json.encode({
            'price': total,
            'dateTime': timeStamp.toIso8601String(),
            'products': cartProducts.map((e) {
              return {
                'id': e.id,
                'title': e.title,
                'quantity': e.quantity,
                'price': e.price,
              };
            }).toList()
          }));

      _orders.insert(
        0,
        OrderItem(
          dateTime: timeStamp,
          id: json.decode(response.body)['name'],
          price: total,
          products: cartProducts,
        ),
      );
    } catch (err) {
      print(err);
    }
  }
}
