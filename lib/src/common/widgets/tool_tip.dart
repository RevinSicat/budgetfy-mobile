import 'package:flutter/material.dart';

void showToolTip(BuildContext context, String message, GlobalKey key) {
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final overlay = Overlay.of(context);
    late OverlayEntry entry; // declare so we can remove it inside GestureDetector

    entry = OverlayEntry(
        builder: (_) => Stack(
            children: [
                Positioned.fill(
                child: GestureDetector(
                        onTap: () => entry.remove(),
                        behavior: HitTestBehavior.translucent,
                        child: Container(color: Colors.transparent)
                    )
                ),
                // Tooltip itself
                Positioned(
                    left: position.dx,
                    top: position.dy - 40,
                    child: Material(
                        color: Colors.transparent,
                        child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                                color: Colors.black87,
                                borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                                message,
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                            )
                        )
                    )
                )
            ]
        )
    );

    overlay.insert(entry);
}