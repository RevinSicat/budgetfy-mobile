import 'package:budgetfy/src/features/category/category.dart';

class CategoryChartData {
    final String categoryId;
    final String name;
    final String color;
    final CategoryType type;
    final double total;

    const CategoryChartData({
        required this.categoryId,
        required this.name,
        required this.color,
        required this.type,
        required this.total,
    });
}