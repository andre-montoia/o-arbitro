import 'package:flutter/material.dart';

/// Dare intensity levels matching the original game design
enum DareIntensity {
  leve,
  medio,
  forte,
  epico,
  castigo,
}

/// Core Dare model for custom dares and theme packs
class Dare {
  final String id;
  final String text;
  final DareIntensity intensity;
  final String? emoji;

  const Dare({
    required this.id,
    required this.text,
    required this.intensity,
    this.emoji,
  });

  @override
  String toString() => 'Dare($id: $text)';
}
