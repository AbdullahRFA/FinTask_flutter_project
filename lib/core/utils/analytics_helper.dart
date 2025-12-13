import 'package:flutter/material.dart';
import '../../features/expenses/domain/expense_model.dart';

class AnalyticsHelper {
  // 1. Calculate Totals by Category
  static Map<String, double> calculateCategoryTotals(List<ExpenseModel> expenses) {
    final Map<String, double> totals = {};

    for (var expense in expenses) {
      if (totals.containsKey(expense.category)) {
        totals[expense.category] = totals[expense.category]! + expense.amount;
      } else {
        totals[expense.category] = expense.amount;
      }
    }
    return totals;
  }

  // 2. Get Color for Category (So the chart looks consistent)
  static Color getCategoryColor(String category) {
    switch (category) {
      case 'Food': return Colors.orange;
      case 'Transport': return Colors.blue;
      case 'Bills': return Colors.red;
      case 'Shopping': return Colors.purple;
      case 'Entertainment': return Colors.pink;
      case 'Health': return Colors.green;
      default: return Colors.grey;
    }
  }
}