import 'package:flutter/material.dart';

class Mantra {
  final String id;
  final String name;
  final String imagePath;
  final MaterialColor primaryColor;
  final MaterialColor secondaryColor;

  const Mantra({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.primaryColor,
    required this.secondaryColor,
  });
}
