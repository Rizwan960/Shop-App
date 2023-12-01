import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';
import 'dart:convert';

import './product.dart';

class ProductsProvider with ChangeNotifier {
  final authToken;
  final userId;
  // ignore: prefer_final_fields
  List<Product> _items = [];

  ProductsProvider(
    this.authToken,
    this.userId,
    this._items,
  );

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prodItem) => prodItem.isFav).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  void showFavoritesOnly() {
    notifyListeners();
  }

  void showAll() {
    notifyListeners();
  }

  Future<void> fetchAndSetProduct([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? '&orderBy="creatorId"&equalTo="$userId"' : '';
    try {
      final responce = await http.get(
        Uri.parse(
            'https://my-first-project-shopapp-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString'),
      );
      final extractedData = json.decode(responce.body) as Map<String, dynamic>;
      final favResponce = await http.get(Uri.parse(
          'https://my-first-project-shopapp-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken'));
      final favResponceData = json.decode(favResponce.body);
      final List<Product> loadedProduct = [];
      extractedData.forEach((productId, productData) {
        loadedProduct.add(
          Product(
            id: productId,
            title: productData['title'],
            description: productData['description'],
            price: productData['price'],
            imageUrl: productData['imageUrl'],
            isFav: favResponceData == null
                ? false
                : favResponceData[productId] ?? false,
          ),
        );
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    try {
      final responce = await http.post(
        Uri.parse(
            'https://my-first-project-shopapp-default-rtdb.firebaseio.com/products.json?auth=$authToken'),
        body: json.encode(
          {
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId
          },
        ),
      );
      final newProduct = Product(
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        id: json.decode(responce.body)['name'],
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      try {
        await http.patch(
            Uri.parse(
              'https://my-first-project-shopapp-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken',
            ),
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            }));
      } catch (error) {
        rethrow;
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {}
  }

  Future<void> deleteProduct(String id) async {
    final exsitingProductIndex =
        _items.indexWhere((element) => element.id == id);
    Product? exsitingProduct = _items[exsitingProductIndex];
    _items.removeWhere((prod) => prod.id == id);
    notifyListeners();
    final responce = await http.delete(
      Uri.parse(
          'https://my-first-project-shopapp-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken'),
    );

    if (responce.statusCode >= 400) {
      _items.insert(exsitingProductIndex, exsitingProduct);
      notifyListeners();
      throw HttpException('Could not Delete the Product Something Went Wrong');
    }
    exsitingProduct = null;
  }
}
