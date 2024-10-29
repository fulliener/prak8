import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:prak8/model/items.dart';
import 'package:prak8/model/person.dart';

class ApiService {
  final Dio _dio = Dio();

  final ip = '10.0.2.2';

  Future<List<Items>> getProducts() async {
    try {
      final response = await _dio.get('http://${ip}:8080/products');
      if (response.statusCode == 200) {
        List<Items> products = (response.data as List)
            .map((product) => Items.fromJson(product))
            .toList();

        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Items>> getFavoriteProducts() async {
    try {
      final response = await _dio.get('http://${ip}:8080/favorite_products');
      if (response.statusCode == 200) {
        List<Items> products = (response.data as List)
            .map((product) => Items.fromJson(product))
            .toList();

        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<Items>> getShopCartProducts() async {
    try {
      final response = await _dio.get('http://${ip}:8080/shop_cart_products');
      if (response.statusCode == 200) {
        List<Items> products = (response.data as List)
            .map((product) => Items.fromJson(product))
            .toList();

        return products;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<int> getCountShopCartProducts() async {
    try {
      final response = await _dio.get('http://${ip}:8080/shop_cart_products');
      if (response.statusCode == 200) {
        int count = (response.data as List).toList().length;

        return count;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Items> getProductsByID(int index) async {
    final link = 'http://${ip}:8080/products/${index.toString()}';
    try {
      final response = await _dio.get(link);
      if (response.statusCode == 200) {
        Items product = Items.fromJson(response.data);
        print(product);
        return product;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<Person> getUserByID(int index) async {
    final link = 'http://${ip}:8080/users/${index.toString()}';
    try {
      final response = await _dio.get(link);
      if (response.statusCode == 200) {
        Person product = Person.fromJson(response.data);
        print(product);
        return product;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<void> updateProductStatus(Items item) async {
    final link = 'http://${ip}:8080/products/update/${item.id}';
    try {
      final response = await _dio.put(link, data: {
        'Name': item.name,
        'Image': item.image,
        'Cost': item.cost,
        'Describtion': item.describtion,
        'Favorite': item.favorite,
        'ShopCart': item.shopcart,
        'Count': item.count,
      });
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<void> updateUser(Person item) async {
    final link = 'http://${ip}:8080/users/update/${item.id}';
    try {
      final response = await _dio.put(link, data: {
        'Name': item.name,
        'Image': item.image,
        'Phone': item.phone,
        'Mail': item.mail,
      });
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<void> deleteProduct(int index) async {
    final link = 'http://${ip}:8080/products/delete/${index}';
    try {
      final response = await _dio.delete(link);
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<void> addProduct(Items item) async {
    final link = 'http://${ip}:8080/products/create';
    try {
      final response = await _dio.post(link, data: {
        'Name': item.name,
        'Image': item.image,
        'Cost': item.cost,
        'Describtion': item.describtion,
        'Favorite': item.favorite,
        'ShopCart': item.shopcart,
        'Count': item.count,
      });
      if (response.statusCode == 200) {
        return;
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }
}