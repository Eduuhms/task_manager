import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final Color color;

  Category({
    required this.id,
    required this.name,
    required this.color,
  });

  // Helper factory to convert color to hex string if needed later
  String colorHex() => '#${color.value.toRadixString(16).padLeft(8, '0')}';

  // Some default categories
  static List<Category> defaults() {
    return [
      Category(id: 'personal', name: 'Pessoal', color: Colors.teal),
      Category(id: 'work', name: 'Trabalho', color: Colors.indigo),
      Category(id: 'shopping', name: 'Compras', color: Colors.deepOrange),
      Category(id: 'others', name: 'Outros', color: Colors.grey),
    ];
  }
}
