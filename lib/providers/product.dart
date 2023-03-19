import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  void _newFav(bool newisFavorite) {
    isFavorite = newisFavorite;
    notifyListeners();
  }

  Future<void> toggleFavoriteStatus(String authToken,String userid) async {
    final recwst = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = Uri.parse(
        'https://test-sowp-default-rtdb.firebaseio.com/userisFavorite/$userid/$id.json?auth=$authToken');
    try {
      final respncwv =
          await http.put(url, body: json.encode(isFavorite));
      if (respncwv.statusCode >= 400) {
        _newFav(recwst);
      }
    } catch (ereero) {
      _newFav(recwst);
     
    }
  }
}
