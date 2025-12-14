import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:monthly_expense_flutter_project/core/utils/currency_helper.dart';
import 'package:monthly_expense_flutter_project/features/wallet/data/wallet_repository.dart';
import '../data/savings_repository.dart';
import '../domain/savings_goal_model.dart';
import 'add_goal_dialog.dart';
import 'deposit_dialog.dart';

class SavingsListScreen extends ConsumerWidget {
  const SavingsListScreen({super.key});

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String goalId, double currentSaved) {
    String? selectedWalletId;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          final walletsAsync = ref.watch(walletListProvider);

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text("Delete Goal?", style: TextStyle(fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Are you sure you want to delete this goal?"),
                const SizedBox(height: 15),
                if (currentSaved > 0) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.teal.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Refund: ${CurrencyHelper.format(currentSaved)}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        const Text("Select a wallet to receive funds:", style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  walletsAsync.when(
                    data: (wallets) {
                      if (wallets.isEmpty) return const Text("No wallets found to refund.");
                      if (selectedWalletId == null && wallets.isNotEmpty) {
                        selectedWalletId = wallets.first.id;
                      }
                      return DropdownButtonFormField<String>(
                        value: selectedWalletId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: "Refund To",
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: wallets.map((w) => DropdownMenuItem(
                          value: w.id,
                          child: Text(w.name),
                        )).toList(),
                        onChanged: (val) => setState(() => selectedWalletId = val),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, s) => Text("Error: $e"),
                  ),
                ] else ...[
                  const Text(
                    "This goal has no funds. It will be deleted permanently.",
                    style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                  ),
                ]
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ref.read(savingsRepositoryProvider).deleteGoal(
                    goalId: goalId,
                    refundWalletId: selectedWalletId,
                  );
                  Navigator.pop(ctx);
                },
                child: Text(currentSaved > 0 ? "Refund & Delete" : "Delete"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsAsync = ref.watch(savingsListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Savings Goals", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text("New Goal"),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        onPressed: () => showDialog(
            context: context,
            builder: (_) => const AddGoalDialog()
        ),
      ),
      body: savingsAsync.when(
        data: (goals) {
          if (goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 80, color: Colors.grey[300]),
                  const SizedBox(height: 16),
                  Text("Dream Big!", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  const Text("Create a goal to start saving.", style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: goals.length,
            itemBuilder: (context, index) {
              return _SavingsGoalCard(
                goal: goals[index],
                onDelete: () => _showDeleteDialog(context, ref, goals[index].id, goals[index].currentSaved),
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

class _SavingsGoalCard extends StatelessWidget {
  final SavingsGoalModel goal;
  final VoidCallback onDelete;

  const _SavingsGoalCard({required this.goal, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final double progress = (goal.targetAmount == 0) ? 0.0 : (goal.currentSaved / goal.targetAmount).clamp(0.0, 1.0);
    final String percentage = (progress * 100).toStringAsFixed(1);
    final bool isCompleted = progress >= 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.teal.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green.shade50 : Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_circle : Icons.track_changes,
                    color: isCompleted ? Colors.green : Colors.teal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Target: ${DateFormat('MMM d, y').format(goal.deadline)}",
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.grey[400]),
                  onPressed: onDelete,
                )
              ],
            ),
            const SizedBox(height: 20),

            // Progress Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Saved", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      CurrencyHelper.format(goal.currentSaved),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("Goal", style: TextStyle(fontSize: 12, color: Colors.grey)),
                    Text(
                      CurrencyHelper.format(goal.targetAmount),
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Stack(
              children: [
                Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: isCompleted ? Colors.green : (progress > 0.5 ? Colors.teal : Colors.orange),
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [
                        BoxShadow(
                          color: (progress > 0.5 ? Colors.teal : Colors.orange).withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                "$percentage% Completed",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[600]),
              ),
            ),

            const SizedBox(height: 20),

            // Deposit Button
            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.arrow_downward_rounded, size: 18),
                label: const Text("Deposit Funds", style: TextStyle(fontWeight: FontWeight.bold)),
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
  }
}