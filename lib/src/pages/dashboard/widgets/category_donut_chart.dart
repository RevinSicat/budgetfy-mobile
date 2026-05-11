import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/design_tokens.dart';
import '../../../features/category/category.dart';
import '../../../features/transaction/transaction.dart';
import '../../../features/transaction/transaction_provider.dart';
import '../../../common/utils/color_utility.dart';
import '../../../common/widgets/forms/transaction_form.dart';
import '../../../features/dashboard/category_chart_data.dart';

class CategoryDonutChart extends ConsumerStatefulWidget {
    const CategoryDonutChart({super.key});

    @override
    ConsumerState<CategoryDonutChart> createState() => CategoryDonutChartState();
}

class CategoryDonutChartState extends ConsumerState<CategoryDonutChart> {
    late int month;
    late int year;
    CategoryType selectedType = CategoryType.expense;
    int? touchedIndex;

    static const monthNames = [
        'January', 'February', 'March', 'April',
        'May', 'June', 'July', 'August',
        'September', 'October', 'November', 'December',
    ];

    @override
    void initState() {
        super.initState();
        final now = DateTime.now();
        month = now.month;
        year  = now.year;
    }

    List<DropdownMenuItem<int>> get monthItems => List.generate(12, (i) =>
        DropdownMenuItem(
            value: i + 1, 
            child: Text(monthNames[i])
        )
    );

    List<DropdownMenuItem<int>> get yearItems {
        final currentYear = DateTime.now().year;

        return List.generate(6, (i) {
            final y = currentYear - 5 + i;

            return DropdownMenuItem(
                value: y, 
                child: Text('$y')
            );
        });
    }

    @override
    Widget build(BuildContext context) {
        final filter       = MonthYearFilter(month: month, year: year);
        final chartAsync   = ref.watch(getCategoryAmountSumByMonthAndYearProvider(filter));
        final theme        = Theme.of(context);

        return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
                color: theme.cardTheme.color,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: theme.brightness == Brightness.dark
                    ? Border.all(color: Colors.white10)
                    : Border.all(color: Colors.grey.shade200),
                boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(
                            theme.brightness == Brightness.light 
                                ? 0.06 
                                : 0.2,
                        ),
                        offset: const Offset(2, 2),
                        blurRadius: 4
                    )
                ]
            ),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    /// Row 1 (Category Type, And Date Selection) =================================
                    Row(
                        children: [
                            /// Category Type Selection ===========================================
                            TypeToggle(
                                selected: selectedType,
                                onChanged: (t) => setState(() {
                                    selectedType  = t;
                                    touchedIndex  = null;
                                }),
                            ),
                            const Spacer(),
                            /// Month Dropdown ====================================================
                            CompactDropdown<int>(
                                value: month,
                                items: monthItems,
                                onChanged: (v) {
                                    if (v == null) {
                                        return;
                                    }
                                    final now = DateTime.now();
                                    if (year == now.year && v > now.month) {
                                        return;
                                    }
                                    setState(() { 
                                        month = v; 
                                        touchedIndex = null; 
                                    });
                                }
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            /// Year Dropdown =====================================================
                            CompactDropdown<int>(
                                value: year,
                                items: yearItems,
                                onChanged: (v) {
                                    if (v == null) return;
                                    final now = DateTime.now();
                                    setState(() {
                                        year = v;
                                        if (year == now.year && month > now.month) {
                                            month = now.month;
                                        }
                                        touchedIndex = null;
                                    });
                                }
                            )
                        ]
                    ),
                    const SizedBox(height: AppSpacing.md),
                    /// Row 2 Chart, Legend =======================================================
                    chartAsync.when(
                        data: (allData) {
                            final filtered = allData
                                .where((d) => d.type == selectedType)
                                .toList()
                                ..sort((a, b) => b.total.compareTo(a.total));

                            if (filtered.isEmpty) {
                                return EmptyState(type: selectedType);
                            }

                            final safeIndex = (touchedIndex != null &&
                                    touchedIndex! >= 0 &&
                                    touchedIndex! < filtered.length)
                                ? touchedIndex
                                : null;

                            return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    /// Chart | Legend ============================================
                                    ChartRow(
                                        data: filtered,
                                        touchedIndex: safeIndex,
                                        onTouch: (index) => setState(() {
                                            touchedIndex = (safeIndex == index) 
                                                ? null 
                                                : index;
                                        })
                                    ),
                                    /// Category Summary ==========================================
                                    if (safeIndex != null) ...[
                                        const SizedBox(height: AppSpacing.lg),
                                        CategorySummaryRow(
                                            item: filtered[safeIndex],
                                            total: filtered.fold(
                                                0.0, (s, d) => s + d.total,
                                            )
                                        )
                                    ],
                                    /// Category Transaction Tile List ============================
                                    if (safeIndex != null) ...[
                                        const SizedBox(height: AppSpacing.sm),
                                        CategoryTransactionList(
                                            categoryId: filtered[safeIndex].categoryId,
                                            month: month,
                                            year: year,
                                        )
                                    ]
                                ]
                            );
                        },
                        loading: () => const SizedBox(
                            height: 180,
                            child: Center(
                                child: CircularProgressIndicator()
                            )
                        ),
                        error: (e, _) => Center(child: Text('Error: $e')),
                    ),
                ],
            ),
        );
    }
}

/* ================================================================================================
Chart | Legend Class
================================================================================================ */
class ChartRow extends StatelessWidget {
    final List<CategoryChartData> data;
    final int? touchedIndex;
    final ValueChanged<int> onTouch;

    const ChartRow({
        required this.data,
        required this.touchedIndex,
        required this.onTouch,
    });

    @override
    Widget build(BuildContext context) {
        final total = data.fold(0.0, (s, d) => s + d.total);

        return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
                /// Pie Chart =====================================================================
                SizedBox(
                    width: 170,
                    height: 170,
                    child: Stack(
                        alignment: Alignment.center,
                        children: [
                            PieChart(
                                PieChartData(
                                    pieTouchData: PieTouchData(
                                        touchCallback: (event, response) {
                                            if (event is! FlTapUpEvent) {
                                                return;
                                            }
                                            if (response == null 
                                                || response.touchedSection == null) {
                                                    return;
                                            }
                                            
                                            final index = response.touchedSection!.touchedSectionIndex;
                                            if (index < 0) {
                                                return; 
                                            }
                                            
                                            onTouch(index);
                                        }
                                    ),
                                    startDegreeOffset: -90,
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 48,
                                    sections: buildSections(data, touchedIndex),
                                )
                            ),
                            CenterLabel(
                                label: touchedIndex != null
                                    ? data[touchedIndex!].name
                                    : 'Total',
                                amount: touchedIndex != null
                                    ? data[touchedIndex!].total
                                    : total
                            )
                        ]
                    )
                ),
                const SizedBox(width: AppSpacing.md),
                /// Legend ========================================================================
                Expanded(
                    child: Legend(
                        data: data,
                        touchedIndex: touchedIndex,
                        total: total,
                        onTap: onTouch
                    )
                )
            ]
        );
    }

    List<PieChartSectionData> buildSections(
        List<CategoryChartData> data,
        int? touchedIndex
    ) {
        final total = data.fold(0.0, (s, d) => s + d.total);
        return List.generate(data.length, (i) {
            final isSelected = i == touchedIndex;
            final color      = hexToColor(data[i].color);
            final pct        = total > 0 ? data[i].total / total * 100 : 0.0;

            return PieChartSectionData(
                color: color.withOpacity(
                    touchedIndex == null || isSelected ? 1.0 : 0.3,
                ),
                value: data[i].total,
                radius: isSelected ? 48 : 38,
                title: isSelected
                    ? '${pct.toStringAsFixed(1)}%'
                    : pct >= 10
                        ? '${pct.toStringAsFixed(0)}%'
                        : '',
                titleStyle: const TextStyle(
                    fontSize: AppFontSize.caption,
                    fontWeight: AppFontWeight.bold,
                    color: Colors.white,
                ),
                titlePositionPercentageOffset: 0.65,
                borderSide: isSelected
                    ? BorderSide(color: color, width: 2)
                    : BorderSide.none,
            );
        });
    }
}

/* ================================================================================================
Pie Chart Center Label Class
================================================================================================ */
class CenterLabel extends StatelessWidget {
    final String label;
    final double amount;

    const CenterLabel({
        required this.label, 
        required this.amount
    });

    String format(double v) {
        if (v >= 1000000) {
            return '₱${(v / 1000000).toStringAsFixed(1)}M';
        }
        if (v >= 1000) {
            return '₱${(v / 1000).toStringAsFixed(1)}K';
        }

        return '₱${v.toStringAsFixed(2)}';
    }

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppFontSize.caption,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(0.65)
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center
                ),
                const SizedBox(height: 2),
                Text(
                    format(amount),
                    style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: AppFontWeight.bold,
                        fontSize: AppFontSize.body
                    ),
                    textAlign: TextAlign.center
                )
            ]
        );
    }
}

/* ================================================================================================
Pie Chart Legend Class
================================================================================================ */
class Legend extends StatelessWidget {
    final List<CategoryChartData> data;
    final int? touchedIndex;
    final double total;
    final ValueChanged<int> onTap;

    const Legend({
        required this.data,
        required this.touchedIndex,
        required this.total,
        required this.onTap,
    });

    @override
    Widget build(BuildContext context) {
        final theme       = Theme.of(context);
        final visible     = data.take(5).toList();
        final othersTotal = data.length > 5
            ? data.skip(5).fold(0.0, (s, d) => s + d.total)
            : 0.0;

        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
                ...visible.asMap().entries.map((e) {
                    final i          = e.key;
                    final item       = e.value;
                    final isSelected = touchedIndex == i;
                    final color      = hexToColor(item.color);
                    final pct        = total > 0
                        ? '${(item.total / total * 100).toStringAsFixed(1)}%'
                        : '0.0%';

                    return GestureDetector(
                        onTap: () => onTap(i),
                        child: Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                            child: AnimatedOpacity(
                                duration: const Duration(milliseconds: 150),
                                opacity: touchedIndex == null || isSelected ? 1.0 : 0.4,
                                child: Row(
                                    children: [
                                        Container(
                                            width: 8, height: 8,
                                            decoration: BoxDecoration(
                                                color: color, 
                                                shape: BoxShape.circle
                                            )
                                        ),
                                        const SizedBox(width: AppSpacing.xs),
                                        Expanded(
                                            child: Text(
                                                item.name,
                                                style: theme.textTheme.bodyMedium?.copyWith(
                                                    fontSize: AppFontSize.caption,
                                                    fontWeight: isSelected
                                                        ? AppFontWeight.bold
                                                        : AppFontWeight.regular,
                                                    color: isSelected
                                                        ? color
                                                        : theme.textTheme.bodyMedium?.color
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis
                                            )
                                        ),
                                        Text(
                                            pct,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: AppFontSize.caption,
                                                fontWeight: isSelected
                                                    ? AppFontWeight.bold
                                                    : AppFontWeight.regular,
                                                color: isSelected
                                                    ? color
                                                    : theme.textTheme.bodyMedium?.color
                                            )
                                        )
                                    ]
                                )
                            )
                        )
                    );
                }),
                if (othersTotal > 0)
                    Row(
                        children: [
                            Container(
                                width: 8, height: 8,
                                decoration: BoxDecoration(
                                    color: Colors.grey.shade400,
                                    shape: BoxShape.circle
                                )
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Expanded(
                                child: Text(
                                    '${data.length - 5} others',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: AppFontSize.caption,
                                        color: Colors.grey
                                    )
                                )
                            ),
                            Text(
                                total > 0
                                    ? '${(othersTotal / total * 100).toStringAsFixed(1)}%'
                                    : '0.0%',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: AppFontSize.caption,
                                    color: Colors.grey
                                )
                            )
                        ]
                    )
            ]
        );
    }
}

/* ================================================================================================
Category Summary Tile
================================================================================================ */
class CategorySummaryRow extends StatelessWidget {
    final CategoryChartData item;
    final double total;

    const CategorySummaryRow({required this.item, required this.total});

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        final color = hexToColor(item.color);
        final pct   = total > 0 ? item.total / total * 100 : 0.0;

        return Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm
            ),
            decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: color.withOpacity(0.3))
            ),
            child: Row(
                children: [
                    Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                            color: color, 
                            shape: BoxShape.circle
                        )
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: Text(
                            item.name,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: AppFontWeight.semiBold,
                                fontSize: AppFontSize.body
                            )
                        )
                    ),
                    Text(
                        '${pct.toStringAsFixed(1)}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: AppFontSize.label,
                            color: color,
                            fontWeight: AppFontWeight.semiBold
                        )
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                        '₱${item.total.toStringAsFixed(2)}',
                        style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: AppFontWeight.bold,
                            fontSize: AppFontSize.body,
                            color: color
                        )
                    )
                ]
            )
        );
    }
}

/* ================================================================================================
Category Transaction List Class
================================================================================================ */
class CategoryTransactionList extends ConsumerWidget {
    final String categoryId;
    final int month;
    final int year;

    const CategoryTransactionList({
        required this.categoryId,
        required this.month,
        required this.year,
    });

    @override
    Widget build(BuildContext context, WidgetRef ref) {
        final theme  = Theme.of(context);
        final filter = CategoryMonthFilter(
            categoryId: categoryId,
            month: month,
            year: year,
        );
        final txAsync = ref.watch(getTransactionsByCategoryAndMonthProvider(filter));

        return txAsync.when(
            loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Text('Error: $e'),
            data: (transactions) {
                if (transactions.isEmpty) {
                    return Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Text(
                            'No transactions for this category.',
                            style: theme.textTheme.bodyMedium,
                        ),
                    );
                }

                return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                        Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs,
                                left: AppSpacing.xs,
                            ),
                            child: Text(
                                '${transactions.length} transaction${transactions.length == 1 ? '' : 's'}',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                    fontSize: AppFontSize.caption,
                                ),
                            ),
                        ),
                        ...transactions.map(
                            (tx) => TransactionRow(transaction: tx),
                        ),
                    ],
                );
            },
        );
    }
}

/* ================================================================================================
Transaction Tile Class
================================================================================================ */
class TransactionRow extends StatelessWidget {
    final Transaction transaction;

    const TransactionRow({required this.transaction});

    @override
    Widget build(BuildContext context) {
        final theme       = Theme.of(context);
        final isIncome    = transaction.category?.type == CategoryType.income;
        final accentColor = isIncome 
            ? Colors.green 
            : Colors.red;
        final accountColor = transaction.account != null
            ? hexToColor(transaction.account!.color)
            : Colors.grey;
        final categoryColor = transaction.category != null
            ? hexToColor(transaction.category!.color)
            : Colors.grey;

        return GestureDetector(
            onTap: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                ),
                builder: (_) => TransactionForm(transaction: transaction)
            ),
            child: Container(
                margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.sm
                ),
                decoration: BoxDecoration(
                    color: theme.scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: theme.brightness == Brightness.dark
                        ? Border.all(color: Colors.white10)
                        : Border.all(color: Colors.grey.shade200)
                ),
                child: Row(
                    children: [
                        /// Transaction Date ======================================================
                        Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                                Text(
                                    '${transaction.date.day}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                        fontWeight: AppFontWeight.bold,
                                        fontSize: AppFontSize.bodyLg
                                    )
                                ),
                                Text(
                                    _shortMonth(transaction.date.month),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                        fontSize: AppFontSize.caption
                                    )
                                )
                            ]
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        /// Transaction Account Badge and Notes ===================================
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                    Row(
                                        children: [
                                            if (transaction.subcategory?.name != null) ...[
                                                Container(
                                                    padding: const EdgeInsets.symmetric(
                                                        horizontal: 6, 
                                                        vertical: 2
                                                    ),
                                                    decoration: BoxDecoration(
                                                        color: categoryColor.withOpacity(0.12),
                                                        borderRadius: BorderRadius.circular(6),
                                                        border: Border.all(
                                                            color: categoryColor.withOpacity(0.4)
                                                        )
                                                    ),
                                                    child: Text(
                                                        transaction.subcategory?.name ?? '—',
                                                        style: theme.textTheme.bodyMedium?.copyWith(
                                                            fontSize: AppFontSize.caption,
                                                            fontWeight: AppFontWeight.semiBold,
                                                            color: categoryColor
                                                        )
                                                    )
                                                ),
                                                const SizedBox(width: AppSpacing.sm)
                                            ],
                                            Container(
                                                padding: const EdgeInsets.symmetric(
                                                    horizontal: 6, 
                                                    vertical: 2
                                                ),
                                                decoration: BoxDecoration(
                                                    color: accountColor.withOpacity(0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                    border: Border.all(
                                                        color: accountColor.withOpacity(0.4)
                                                    )
                                                ),
                                                child: Text(
                                                    transaction.account?.name ?? '—',
                                                    style: theme.textTheme.bodyMedium?.copyWith(
                                                        fontSize: AppFontSize.caption,
                                                        fontWeight: AppFontWeight.semiBold,
                                                        color: accountColor
                                                    )
                                                )
                                            )
                                        ]
                                    ),
                                    if (transaction.note.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                            transaction.note,
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                                fontSize: AppFontSize.caption
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis
                                        )
                                    ]
                                ]
                            )
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        /// Transaction Amount ====================================================
                        Text(
                            '${isIncome ? '+' : ''}₱${transaction.amount.abs().toStringAsFixed(2)}',
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: accentColor,
                                fontWeight: AppFontWeight.bold,
                                fontSize: AppFontSize.body
                            )
                        )
                    ]
                )
            )
        );
    }

    static const _shortMonths = [
        'Jan', 'Feb', 'Mar', 'Apr', 
        'May', 'Jun', 'Jul', 'Aug', 
        'Sep', 'Oct', 'Nov', 'Dec'
    ];

    String _shortMonth(int m) => _shortMonths[m - 1];
}

/* ================================================================================================
Category Type Class
================================================================================================ */
class TypeToggle extends StatelessWidget {
    final CategoryType selected;
    final ValueChanged<CategoryType> onChanged;

    const TypeToggle({
        required this.selected, 
        required this.onChanged
    });

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);

        return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
                Chip(
                    label: 'Expense',
                    isSelected: selected == CategoryType.expense,
                    activeColor: Colors.red,
                    onTap: () => onChanged(CategoryType.expense),
                    theme: theme
                ),
                const SizedBox(width: AppSpacing.xs),
                Chip(
                    label: 'Income',
                    isSelected: selected == CategoryType.income,
                    activeColor: Colors.green,
                    onTap: () => onChanged(CategoryType.income),
                    theme: theme
                )
            ]
        );
    }
}

class Chip extends StatelessWidget {
    final String label;
    final bool isSelected;
    final Color activeColor;
    final VoidCallback onTap;
    final ThemeData theme;

    const Chip({
        required this.label,
        required this.isSelected,
        required this.activeColor,
        required this.onTap,
        required this.theme,
    });

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs
                ),
                decoration: BoxDecoration(
                    color: isSelected ? activeColor.withOpacity(0.12) : Colors.transparent,
                    border: Border.all(
                        color: isSelected ? activeColor : theme.disabledColor,
                        width: isSelected ? 2 : 1
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm)
                ),
                child: Text(
                    label,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        color: isSelected ? activeColor : theme.disabledColor,
                        fontWeight: isSelected ? AppFontWeight.bold : AppFontWeight.regular,
                        fontSize: AppFontSize.label
                    )
                )
            )
        );
    }
}

/* ================================================================================================
Compact Dropdown Class
================================================================================================ */
class CompactDropdown<T> extends StatelessWidget {
    final T value;
    final List<DropdownMenuItem<T>> items;
    final ValueChanged<T?> onChanged;

    const CompactDropdown({
        required this.value,
        required this.items,
        required this.onChanged
    });

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        return Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            decoration: BoxDecoration(
                border: Border.all(color: theme.dividerColor),
                borderRadius: BorderRadius.circular(AppRadius.sm)
            ),
            child: DropdownButtonHideUnderline(
                child: DropdownButton<T>(
                    value: value,
                    items: items,
                    onChanged: onChanged,
                    isDense: true,
                    style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: AppFontSize.label,
                        fontWeight: AppFontWeight.semiBold
                    ),
                    icon: const Icon(Icons.expand_more, size: 16)
                )
            )
        );
    }
}

/* ================================================================================================
Empty State Class
================================================================================================ */
class EmptyState extends StatelessWidget {
    final CategoryType type;
    const EmptyState({required this.type});

    @override
    Widget build(BuildContext context) {
        final theme = Theme.of(context);
        return SizedBox(
            height: 160,
            child: Center(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Icon(
                            Icons.pie_chart_outline, 
                            size: 40, 
                            color: theme.disabledColor
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                            'No ${type == CategoryType.expense ? 'expense' : 'income'} data',
                            style: theme.textTheme.bodyMedium
                        )
                    ]
                )
            )
        );
    }
}