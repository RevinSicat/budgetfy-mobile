import 'package:flutter/material.dart';

class TriangleIndicator extends StatelessWidget {
    final bool isIncome;
    const TriangleIndicator({super.key, required this.isIncome});

    @override
    Widget build(BuildContext context) {
        return CustomPaint(
            size: const Size(20, 20),
            painter: TrianglePainter(
                color: isIncome ? Colors.green : Colors.red,
                pointingUp: isIncome,
            ),
        );
    }
}

class TrianglePainter extends CustomPainter {
    final Color color;
    final bool pointingUp;
    TrianglePainter({required this.color, required this.pointingUp});

    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()..color = color;
        final path = Path();
        if (pointingUp) {
            path.moveTo(size.width / 2, 0);
            path.lineTo(0, size.height);
            path.lineTo(size.width, size.height);
        } else {
            path.moveTo(0, 0);
            path.lineTo(size.width, 0);
            path.lineTo(size.width / 2, size.height);
        }
        path.close();
        canvas.drawPath(path, paint);
    }

    @override
    bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}