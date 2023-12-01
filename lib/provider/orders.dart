import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:http/http.dart' as http;

class OrderItem {
  final String id;
  final int ammount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.ammount,
    required this.products,
    required this.dateTime,
  });
}

class Order with ChangeNotifier {
  final authToken;
  final userId;
  List<OrderItem> _orders = [];

  Order(this.authToken, this.userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrder() async {
    final responce = await http.get(
      Uri.parse(
          'https://my-first-project-shopapp-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken'),
    );
    final List<OrderItem> loadedProduct = [];
    final extractedData = json.decode(responce.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedProduct.add(
        OrderItem(
          id: orderId,
          ammount: orderData['ammount'],
          products: (orderData['products'] as List<dynamic>)
              .map((e) => CartItem(
                  id: e['id'],
                  title: e['title'],
                  quantity: e['quantity'],
                  price: e['price']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime']),
        ),
      );
    });
    _orders = loadedProduct.reversed.toList();
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProduct, int amount) async {
    final timeStamp = DateTime.now();

    final responce = await http.post(
        Uri.parse(
            'https://my-first-project-shopapp-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken'),
        body: json.encode({
          'ammount': amount,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProduct
              .map((e) => {
                    'id': e.id,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price
                  })
              .toList(),
        }));

    _orders.insert(
      0,
      OrderItem(
        id: json.decode(responce.body)['name'],
        ammount: amount,
        products: cartProduct,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }
}
