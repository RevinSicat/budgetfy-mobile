import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'category_provider.dart';

class CategoryScreen extends ConsumerWidget {
    const CategoryScreen({super.key});

    Color hexToColor(String hex) {
        hex = hex.replaceAll('#', '');
        if (hex.length == 6) {
            hex = 'FF$hex';
        }
        return Color(int.parse(hex, radix: 16));
    }

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final categoryList = ref.watch(categoryListProvider);
        return Scaffold(
            appBar: AppBar(title: const Text('Categories')),
            body: categoryList.when(
                data: (categories) => ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                        final category = categories[index];
                        return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4
                            ),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color: hexToColor(category.color),
                                    width: 2
                                ),
                                borderRadius: BorderRadius.circular(8)
                            ),
                            child: ListTile(
                                title: Text(category.name),
                                trailing: TriangleIndicator(isIncome: category.type.name == 'income')
                            )
                        );
                    }
                ),
                loading: () => const Center(
                    child: CircularProgressIndicator()
                ),
                error: (e, _) => Center(
                    child: Text('Error encountered: $e')
                )
            ),
        );
    }
}

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
    TrianglePainter({
        required this.color, 
        required this.pointingUp
    });

    @override
    void paint(Canvas canvas, Size size) {
        final paint = Paint()..color = color;
        final path = Path();

        if (pointingUp) {
        // Upright triangle
        path.moveTo(size.width / 2, 0);
        path.lineTo(0, size.height);
        path.lineTo(size.width, size.height);
        } else {
        // Inverted triangle
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