import 'package:flutter/material.dart';

const List<String> colorList = [
  '#EF5350', '#EC407A', '#F06292', '#D81B60',
  '#AB47BC', '#8E24AA', '#7E57C2', '#6A1B9A',
  '#5C6BC0', '#42A5F5', '#1E88E5', '#1565C0',
  '#26A69A', '#66BB6A', '#43A047', '#2E7D32',
  '#FFA726', '#FB8C00', '#FDD835', '#FBC02D',
  '#78909C', '#546E7A', '#455A64', '#37474F',
];

Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
        hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
}