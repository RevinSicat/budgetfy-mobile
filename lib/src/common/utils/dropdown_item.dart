import 'package:flutter/material.dart';

Widget dropdownItem(BuildContext context, Color color, String name) {
    final theme = Theme.of(context);
    
    return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
            Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle
                )
            ),
            const SizedBox(width: 12),
            Text(
                name,
                style: theme.textTheme.bodyLarge
            )
        ]
    );
}