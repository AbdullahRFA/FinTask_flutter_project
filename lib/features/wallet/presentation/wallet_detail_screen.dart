import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_flutter_project/features/wallet/domain/wallet_model.dart';
import 'package:monthly_expense_flutter_project/features/wallet/data/wallet_repository.dart';
import 'package:monthly_expense_flutter_project/features/expenses/data/expense_repository.dart';
import 'package:monthly_expense_flutter_project/features/expenses/presentation/add_expense_dialog.dart';
import 'package:monthly_expense_flutter_project/core/utils/expense_grouper.dart';
import 'package:monthly_expense_flutter_project/features/analytics/presentation/category_pie_chart.dart';
class WalletDetailScreen extends ConsumerWidget {
  final WalletModel wallet;

  const WalletDetailScreen({super.key, required this.wallet});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch Expenses List
    final expensesAsync = ref.watch(expenseListProvider(wallet.id));

    // 2. Watch Wallet Balance (Live!)
    final walletAsync = ref.watch(walletStreamProvider(wallet.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(wallet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.pie_chart),
            tooltip: "View Analytics",
            onPressed: () {
              // We need the expenses list to show the chart.
              // We read the current state of the provider.
              final expensesState = ref.read(expenseListProvider(wallet.id));

              if (expensesState.hasValue) {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Container(
                    padding: const EdgeInsets.all(16),
                    height: 400,
                    child: Column(
                      children: [
                        const Text("Spending Breakdown", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        // Pass the list to our new Chart Widget
                        CategoryPieChart(expenses: expensesState.value!),
                      ],
                    ),
                  ),
                );
              }
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (_) => AddExpenseDialog(walletId: wallet.id),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // --- LIVE HEADER ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.teal.shade50,
            child: walletAsync.when(
              // Success: Show live data
              data: (liveWallet) => Column(
                children: [
                  const Text("Current Balance", style: TextStyle(color: Colors.grey)),
                  Text(
                    "${liveWallet.currentBalance}",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  Text("Monthly Budget: ${liveWallet.monthlyBudget}"),
                ],
              ),
              // Loading: Show old data (so it doesn't flicker)
              loading: () => Column(
                children: [
                  const Text("Current Balance", style: TextStyle(color: Colors.grey)),
                  Text(
                    "${wallet.currentBalance}...",
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Text("Monthly Budget: ${wallet.monthlyBudget}"),
                ],
              ),
              // Error: Show message
              error: (err, stack) => Text("Error loading balance: $err"),
            ),
          ),

          // --- EXPENSE LIST ---
          // --- EXPENSE LIST (GROUPED) ---
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const Center(child: Text("No expenses yet. Spend some money!"));
                }

                // 1. Group the expenses
                final groupedMap = ExpenseGrouper.groupExpensesByDate(expenses);
                final dateKeys = groupedMap.keys.toList();

                // 2. Build the list
                return ListView.builder(
                  itemCount: dateKeys.length,
                  itemBuilder: (context, index) {
                    final dateKey = dateKeys[index];
                    final dayExpenses = groupedMap[dateKey]!;
                    final headerText = ExpenseGrouper.getNiceHeader(dateKey);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. The Daily Header (e.g. "Today")
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: Text(
                            headerText,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // B. The List of Expenses for that day
                        ...dayExpenses.map((expense) {
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                            elevation: 1, // Slight shadow looks nice
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                child: Icon(_getIconForCategory(expense.category), color: Colors.teal),
                              ),
                              title: Text(expense.title),
                              subtitle: Text(expense.category),
                              trailing: Text(
                                "-${expense.amount}",
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text("Error: $err")),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Food': return Icons.fastfood;
      case 'Transport': return Icons.directions_bus;
      case 'Bills': return Icons.receipt;
      case 'Shopping': return Icons.shopping_bag;
      case 'Entertainment': return Icons.movie;
      case 'Health': return Icons.local_hospital;
      default: return Icons.attach_money;
    }
  }
}