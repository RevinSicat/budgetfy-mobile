import 'package:flutter/material.dart';

const List<String> colorList = [
    '#EF5350', '#EC407A', '#AB47BC', '#5C6BC0',
    '#42A5F5', '#26A69A', '#66BB6A', '#FFA726',
];

Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
        hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
}