import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/analytics_helper.dart';
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
      return const SizedBox(height: 200, child: Center(child: Text("No data to chart")));
    }

    // Sort categories by amount (Biggest first) - Looks better
    final sortedEntries = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // 2. Prepare Chart Sections
    final sections = sortedEntries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalSpent) * 100;
      final color = AnalyticsHelper.getCategoryColor(category);

      return PieChartSectionData(
        color: color,
        value: amount,
        // Only show text on chart if slice is big enough (> 5%)
        title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 40,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        // --- THE CHART ---
        SizedBox(
          height: 200,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sections: sections,
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Total", style: TextStyle(fontSize: 10, color: Colors.grey)),
                  Text(
                    "${totalSpent.toStringAsFixed(0)}",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),

        const SizedBox(height: 20),

        // --- THE LEGEND (Breakdown List) ---
        // We use a shrinkWrap ListView to list the categories below
        ListView.builder(
          shrinkWrap: true, // Takes only needed space
          physics: const NeverScrollableScrollPhysics(), // Don't scroll separately
          itemCount: sortedEntries.length,
          itemBuilder: (context, index) {
            final entry = sortedEntries[index];
            final category = entry.key;
            final amount = entry.value;
            final percentage = (amount / totalSpent) * 100;
            final color = AnalyticsHelper.getCategoryColor(category);

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: Row(
                children: [
                  // Color Indicator
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Category Name
                  Text(category, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const Spacer(),

                  // Percentage & Amount
                  Text(
                    "${percentage.toStringAsFixed(1)}%",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "${amount.toStringAsFixed(0)}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}