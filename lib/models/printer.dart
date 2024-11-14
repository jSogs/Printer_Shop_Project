import 'package:flutter/material.dart';

class Printer{
  final String name;
  final String imageURL;
  final double price;
  final List<Color> colors;
  final List<String> tags;

  Printer({required this.name, required this.imageURL, required this.price, required this.colors, required this.tags});
}