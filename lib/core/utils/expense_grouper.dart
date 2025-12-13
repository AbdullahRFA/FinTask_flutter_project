import 'package:intl/intl.dart';
import '../../features/expenses/domain/expense_model.dart';

class ExpenseGrouper {
  // We return a Map where the Key is a String (e.g., "2025-10-12")
  // and the Value is the list of expenses for that day.
  static Map<String, List<ExpenseModel>> groupExpensesByDate(List<ExpenseModel> expenses) {
    final Map<String, List<ExpenseModel>> grouped = {};

    for (var expense in expenses) {
      // We format the date to YYYY-MM-DD so we can compare days ignoring time
      final String dateKey = DateFormat('yyyy-MM-dd').format(expense.date);

      if (grouped.containsKey(dateKey)) {
        grouped[dateKey]!.add(expense);
      } else {
        grouped[dateKey] = [expense];
      }
    }
    return grouped;
  }

  // Helper to get a nice header text (e.g., "Today", "Yesterday", "Oct 12")
  static String getNiceHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return "Today";
    } else if (dateToCheck == yesterday) {
      return "Yesterday";
    } else {
      return DateFormat('MMM d, y').format(date);
    }
  }
}