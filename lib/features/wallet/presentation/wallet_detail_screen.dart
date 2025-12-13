import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_flutter_project/features/wallet/domain/wallet_model.dart';
import 'package:monthly_expense_flutter_project/features/wallet/data/wallet_repository.dart';
import 'package:monthly_expense_flutter_project/features/expenses/data/expense_repository.dart';
import 'package:monthly_expense_flutter_project/features/expenses/presentation/add_expense_dialog.dart';

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
      appBar: AppBar(title: Text(wallet.name)),
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
          Expanded(
            child: expensesAsync.when(
              data: (expenses) {
                if (expenses.isEmpty) {
                  return const Center(child: Text("No expenses yet. Spend some money!"));
                }
                return ListView.builder(
                  itemCount: expenses.length,
                  itemBuilder: (context, index) {
                    final expense = expenses[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(expense.category[0]),
                      ),
                      title: Text(expense.title),
                      subtitle: Text(DateFormat('MMM d, y - h:mm a').format(expense.date)),
                      trailing: Text(
                        "-${expense.amount}",
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
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
}