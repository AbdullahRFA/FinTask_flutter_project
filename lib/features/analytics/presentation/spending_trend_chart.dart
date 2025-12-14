import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../expenses/domain/expense_model.dart';
import '../../../core/utils/expense_grouper.dart';

class SpendingTrendChart extends StatelessWidget {
  final List<ExpenseModel> expenses;

  const SpendingTrendChart({super.key, required this.expenses});

  @override
  Widget build(BuildContext context) {
    // 1. Group Data by Day
    final grouped = ExpenseGrouper.groupExpensesByDate(expenses);
    final sortedKeys = grouped.keys.toList()..sort();

    // Show last 7 active days
    final displayKeys = sortedKeys.length > 7 ? sortedKeys.sublist(sortedKeys.length - 7) : sortedKeys;

    if (displayKeys.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.grey.shade100),
        ),
        child: const Center(
          child: Text("No spending history available", style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    double maxY = 0;
    final List<BarChartGroupData> barGroups = [];

    for (int i = 0; i < displayKeys.length; i++) {
      final key = displayKeys[i];
      final dayExpenses = grouped[key]!;

      final dailyTotal = dayExpenses
          .where((e) => e.amount > 0)
          .fold(0.0, (sum, e) => sum + e.amount);

      if (dailyTotal > maxY) maxY = dailyTotal;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: dailyTotal,
              gradient: LinearGradient(
                colors: [Colors.teal.shade300, Colors.teal.shade700],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              width: 18,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
              backDrawRodData: BackgroundBarChartRodData(
                show: true,
                toY: maxY * 1.1,
                color: Colors.grey.shade100,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.bar_chart_rounded, color: Colors.teal, size: 20),
              ),
              const SizedBox(width: 12),
              const Text("Daily Spending Trend", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 30),
          AspectRatio(
            aspectRatio: 1.5,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.1,
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    tooltipBgColor: Colors.blueGrey.shade900, // <--- FIXED HERE
                    tooltipRoundedRadius: 8,
                    tooltipPadding: const EdgeInsets.all(12),
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final key = displayKeys[group.x.toInt()];
                      final date = DateTime.parse(key);
                      return BarTooltipItem(
                        "${DateFormat('EEE, MMM d').format(date)}\n",
                        const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                        children: [
                          TextSpan(
                            text: rod.toY.toStringAsFixed(0),
                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= displayKeys.length) return const SizedBox();

                        final date = DateTime.parse(displayKeys[index]);
                        return Padding(
                          padding: const EdgeInsets.only(top: 10.0),
                          child: Text(
                            DateFormat('d').format(date),
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY / 5 > 0 ? maxY / 5 : 1,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Colors.grey.shade100,
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ),
                barGroups: barGroups,
              ),
            ),
          ),
        ],
      ),
    );
  }
}