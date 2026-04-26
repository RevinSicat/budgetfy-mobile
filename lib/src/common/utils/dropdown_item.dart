import 'package:flutter/material.dart';

Widget dropdownItem(Color color, String name) {
    return Row(
        children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                ),
            ),
            const SizedBox(width: 12),
            Text(name),
        ],
    );
}