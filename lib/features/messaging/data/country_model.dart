import 'dart:convert';
import 'package:flutter/services.dart';

class Country {
  final String name;
  final String dialCode;
  final String code;

  const Country({
    required this.name,
    required this.dialCode,
    required this.code,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      name: json['name'] as String,
      dialCode: json['dial_code'] as String,
      code: json['code'] as String,
    );
  }

  static Future<List<Country>> loadCountries() async {
    final String response =
        await rootBundle.loadString('assets/data/country_dial_code.json');
    final List<dynamic> data = json.decode(response);
    return data.map((json) => Country.fromJson(json)).toList();
  }
}
