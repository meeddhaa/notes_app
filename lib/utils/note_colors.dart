import 'package:flutter/material.dart';
const List<String> noteColorPalette = [
  '#F3E8FF', // lavender (default)
  '#FCE7F3', // blush pink
  '#DBEAFE', // sky blue
  '#D1FAE5', // mint green
  '#FEF3C7', // warm yellow
  '#FFE4E6', // soft rose
];

const String defaultNoteColor = '#F3E8FF';

Color hexToColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  return Color(int.parse('FF$cleaned', radix: 16));
}


Color hexToAccentColor(String hex) {
  final base = hexToColor(hex);
  final hsl = HSLColor.fromColor(base);
  return hsl.withLightness((hsl.lightness - 0.30).clamp(0.0, 1.0)).toColor();
}