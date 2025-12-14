import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_flutter_project/core/utils/currency_helper.dart'; // Import this
import '../data/savings_repository.dart';
import 'add_goal_dialog.dart';
import 'deposit_dialog.dart';

class SavingsListScreen extends ConsumerWidget {
  const SavingsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(savingsListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Savings Goals")),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("New Goal"),
        onPressed: () => showDialog(
            context: context,
            builder: (_) => const AddGoalDialog()
        ),
      ),
      body: savingsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return const Center(
              child: Text("No goals yet. Dream big!", style: TextStyle(fontSize: 18, color: Colors.grey)),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              final goal = goals[index];
              final progress = (goal.currentSaved / goal.targetAmount).clamp(0.0, 1.0);
              final percentage = (progress * 100).toStringAsFixed(1);

              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header: Title and Menu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(goal.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.grey),
                            onPressed: () {
                              ref.read(savingsRepositoryProvider).deleteGoal(goal.id);
                            },
                          )
                        ],
                      ),

                      // Deadline
                      Text(
                        "Target: ${DateFormat('MMM d, y').format(goal.deadline)}",
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 15),

                      // Progress Bar
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 10,
                        backgroundColor: Colors.grey[200],
                        color: Colors.teal,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      const SizedBox(height: 10),

                      // Stats Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${CurrencyHelper.format(goal.currentSaved)} / ${CurrencyHelper.format(goal.targetAmount)}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("$percentage%", style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Deposit Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.arrow_downward),
                          label: const Text("Deposit Funds"),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => DepositDialog(goalId: goal.id, goalTitle: goal.title),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text("Error: $e")),
      ),
    );
  }
}