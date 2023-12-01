import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String? id;
  final String title;
  final String description;
  final int price;
  final String imageUrl;
  bool isFav;

  Product(
      {this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFav = false});

  Future<void> toggleFavStatus(String authToken, String userId) async {
    final oldStatus = isFav;
    isFav = !isFav;
    notifyListeners();
    try {
      final responce = await http.put(
        Uri.parse(
            'https://my-first-project-shopapp-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken'),
        body: json.encode(
          isFav,
        ),
      );
      if (responce.statusCode >= 400) {
        isFav = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFav = oldStatus;
      notifyListeners();
    }
  }
}
