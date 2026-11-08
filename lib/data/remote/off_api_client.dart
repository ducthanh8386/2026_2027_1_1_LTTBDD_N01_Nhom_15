import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../models/food.dart';

enum OffExceptionType {
  noInternet,
  notFound,
  timeout,
  parse,
  unknown,
}

class OffApiException implements Exception {
  final OffExceptionType type;
  final String message;
  final Object? originalError;

  const OffApiException(this.type, this.message, [this.originalError]);

  @override
  String toString() => 'OffApiException($type, $message)';
}

class OffApiClient {
  final http.Client _client;
  final Duration timeoutDuration;

  static const String userAgent =
      'FitTrack - Flutter - Version 1.0.0 (https://github.com/ducthanh8386/fit-track)';

  OffApiClient({
    http.Client? client,
    this.timeoutDuration = const Duration(seconds: 10),
  }) : _client = client ?? http.Client();

  /// Fetches a food product from Open Food Facts API v2 by its barcode.
  Future<Food> fetchProduct(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) {
      throw const OffApiException(
        OffExceptionType.notFound,
        'Barcode cannot be empty',
      );
    }

    final uri = Uri.parse(
      'https://world.openfoodfacts.org/api/v2/product/$cleanBarcode.json',
    );

    http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: {
          'User-Agent': userAgent,
          'Accept': 'application/json',
        },
      ).timeout(timeoutDuration);
    } on SocketException catch (e) {
      throw OffApiException(
        OffExceptionType.noInternet,
        'No internet connection',
        e,
      );
    } on http.ClientException catch (e) {
      // In web or some platforms, ClientException wraps socket/network failures
      throw OffApiException(
        OffExceptionType.noInternet,
        'Network error: ${e.message}',
        e,
      );
    } on TimeoutException catch (e) {
      throw OffApiException(
        OffExceptionType.timeout,
        'Request timed out after ${timeoutDuration.inSeconds}s',
        e,
      );
    } catch (e) {
      if (e is OffApiException) rethrow;
      final msg = e.toString().toLowerCase();
      if (msg.contains('socket') || msg.contains('failed host lookup') || msg.contains('network')) {
        throw OffApiException(
          OffExceptionType.noInternet,
          'No internet connection',
          e,
        );
      }
      throw OffApiException(
        OffExceptionType.unknown,
        'Unexpected connection error: $e',
        e,
      );
    }

    if (response.statusCode == 404) {
      throw const OffApiException(
        OffExceptionType.notFound,
        'Product not found on Open Food Facts',
      );
    }

    if (response.statusCode != 200) {
      throw OffApiException(
        OffExceptionType.unknown,
        'Server returned HTTP status ${response.statusCode}',
      );
    }

    Map<String, dynamic> jsonBody;
    try {
      jsonBody = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw OffApiException(
        OffExceptionType.parse,
        'Failed to parse JSON response',
        e,
      );
    }

    // Check status field in Open Food Facts JSON (1 = found, 0 = not found)
    final status = jsonBody['status'];
    if (status == 0 || jsonBody['product'] == null) {
      throw const OffApiException(
        OffExceptionType.notFound,
        'Product not found on Open Food Facts',
      );
    }

    try {
      final product = jsonBody['product'] as Map<String, dynamic>;
      return _parseProduct(cleanBarcode, product);
    } catch (e) {
      throw OffApiException(
        OffExceptionType.parse,
        'Failed to parse product data: $e',
        e,
      );
    }
  }

  Food _parseProduct(String barcode, Map<String, dynamic> product) {
    // Product Name: try localized name, then default name
    String name = (product['product_name_vi'] as String?)?.trim() ?? '';
    if (name.isEmpty) {
      name = (product['product_name'] as String?)?.trim() ?? '';
    }
    if (name.isEmpty) {
      name = (product['product_name_en'] as String?)?.trim() ?? '';
    }
    if (name.isEmpty) {
      name = 'Sản phẩm ($barcode)';
    }

    // Brand
    final brand = (product['brands'] as String?)?.trim();

    // Image URL: try front, then generic image
    String? imageUrl = product['image_front_url'] as String?;
    imageUrl ??= product['image_url'] as String?;
    imageUrl ??= product['image_front_small_url'] as String?;

    // Nutriments map
    final nutriments = (product['nutriments'] as Map<String, dynamic>?) ?? {};

    // Energy / Calories in kcal
    double kcal100g = _extractNumber(nutriments, [
      'energy-kcal_100g',
      'energy-kcal',
      'energy-kcal_value',
    ]);
    if (kcal100g == 0.0) {
      // If only kJ is available, convert kJ to kcal (1 kcal ≈ 4.184 kJ)
      final kj = _extractNumber(nutriments, ['energy_100g', 'energy']);
      if (kj > 0) {
        kcal100g = (kj / 4.184).roundToDouble();
      }
    }

    // Protein
    final protein100g = _extractNumber(nutriments, [
      'proteins_100g',
      'proteins',
      'proteins_value',
    ]);

    // Carbohydrates
    final carbs100g = _extractNumber(nutriments, [
      'carbohydrates_100g',
      'carbohydrates',
      'carbohydrates_value',
    ]);

    // Fat
    final fat100g = _extractNumber(nutriments, [
      'fat_100g',
      'fat',
      'fat_value',
    ]);

    return Food(
      barcode: barcode,
      name: name,
      brand: (brand != null && brand.isNotEmpty) ? brand : null,
      kcal100g: kcal100g,
      protein100g: protein100g,
      carbs100g: carbs100g,
      fat100g: fat100g,
      imageUrl: imageUrl,
      source: 'off',
    );
  }

  double _extractNumber(Map<String, dynamic> map, List<String> candidateKeys) {
    for (final key in candidateKeys) {
      if (map.containsKey(key) && map[key] != null) {
        final val = map[key];
        if (val is num) {
          return val.toDouble();
        }
        if (val is String) {
          final parsed = double.tryParse(val.replaceAll(',', '.'));
          if (parsed != null) return parsed;
        }
      }
    }
    return 0.0;
  }
}
