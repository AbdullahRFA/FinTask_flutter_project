import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/analytics_helper.dart';
import '../../../core/utils/currency_helper.dart';
import '../../expenses/domain/expense_model.dart';

class CategoryPieChart extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const CategoryPieChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // 1. Do the Math
    final categoryTotals = AnalyticsHelper.calculateCategoryTotals(expenses);
    final totalSpent = expenses.fold(0.0, (sum, item) => sum + item.amount);

    if (totalSpent == 0) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey[300]),
              const SizedBox(height: 8),
              Text("No expenses to chart", style: TextStyle(color: Colors.grey[500])),
            ],
          ),
        ),
      );
    }

    // Sort categories by amount (Biggest first)
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 2. Prepare Chart Sections
    final sections = sortedEntries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalSpent) * 100;
      final color = AnalyticsHelper.getCategoryColor(category);
      final isLarge = percentage > 15;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: percentage > 4 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: isLarge ? 55 : 45, // Pop out larger slices slightly
        titleStyle: TextStyle(
          fontSize: isLarge ? 14 : 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black.withOpacity(0.2), blurRadius: 2)],
        ),
        badgeWidget: _buildBadge(icon: Icons.star, size: 0, color: color), // Placeholder for future icons
        badgePositionPercentageOffset: .98,
      );
    }).toList();

    return Column(
      children: [
        // --- THE DONUT CHART ---
        SizedBox(
          height: 220,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 50,
                  sectionsSpace: 4,
                  startDegreeOffset: -90,
                ),
              ),
              // Center Text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Total Spent", style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Text(
                    CurrencyHelper.format(totalSpent),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 24),

        // --- THE RICH LEGEND ---
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedEntries.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            final category = entry.key;
            final amount = entry.value;
            final percentage = (amount / totalSpent);
            final color = AnalyticsHelper.getCategoryColor(category);

            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade100, blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: Row(
                children: [
                  // Color Pill
                  Container(
                    width: 4,
                    height: 36,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Category Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        const SizedBox(height: 4),
                        // Mini Progress Bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: percentage,
                            minHeight: 4,
                            backgroundColor: Colors.grey[100],
                            color: color.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 16),

                  // Numbers
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyHelper.format(amount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      Text(
                        "${(percentage * 100).toStringAsFixed(1)}%",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Placeholder helper if we ever want to add icons to badges
  Widget _buildBadge({required IconData icon, required double size, required Color color}) {
    if (size == 0) return const SizedBox.shrink();
    return Container(
      padding: EdgeInsets.all(size * 0.2),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 2)],
      ),
      child: Icon(icon, size: size, color: color),
    );
  }
}