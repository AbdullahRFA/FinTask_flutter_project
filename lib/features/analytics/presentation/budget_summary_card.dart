import 'package:flutter/material.dart';
import '../../../core/utils/currency_helper.dart';

class BudgetSummaryCard extends StatelessWidget {
  final double monthlyBudget;
  final double totalSpent;

  const BudgetSummaryCard({
    super.key,
    required this.monthlyBudget,
    required this.totalSpent,
  });

  @override
  Widget build(BuildContext context) {
    // Logic
    final double remaining = monthlyBudget - totalSpent;
    final double progress = (monthlyBudget == 0) ? 0 : (totalSpent / monthlyBudget);
    final double clampedProgress = progress.clamp(0.0, 1.0);
    final bool isOverBudget = totalSpent > monthlyBudget;

    // Color Logic
    Color statusColor;
    if (isOverBudget) {
      statusColor = Colors.red;
    } else if (progress > 0.85) {
      statusColor = Colors.orange;
    } else {
      statusColor = Colors.teal;
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Budget Usage", style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: statusColor
                        ),
                      ),
                      Text(
                        " used",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500], fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOverBudget ? Icons.warning_amber_rounded : Icons.pie_chart_rounded,
                  color: statusColor,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Custom Progress Bar
          Stack(
            children: [
              Container(
                height: 16,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: clampedProgress,
                child: Container(
                  height: 16,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [statusColor.withOpacity(0.7), statusColor],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(color: statusColor.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: "Limit",
                  amount: monthlyBudget,
                  icon: Icons.account_balance_wallet_outlined,
                  color: Colors.grey.shade700,
                  bgColor: Colors.grey.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: "Spent",
                  amount: totalSpent,
                  icon: Icons.shopping_bag_outlined,
                  color: Colors.orange.shade800,
                  bgColor: Colors.orange.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatBox(
                  label: "Left",
                  amount: remaining,
                  icon: Icons.savings_outlined,
                  color: remaining < 0 ? Colors.red : Colors.green,
                  bgColor: remaining < 0 ? Colors.red.shade50 : Colors.green.shade50,
                ),
              ),
            ],
          ),

          // Over Budget Warning
          if (isOverBudget) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "You exceeded your budget by ${CurrencyHelper.format(totalSpent - monthlyBudget)}",
                      style: TextStyle(color: Colors.red.shade900, fontWeight: FontWeight.w600, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _StatBox({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color.withOpacity(0.8)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 11, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              CurrencyHelper.format(amount),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: color),
            ),
          ),
        ],
      ),
    );
  }
}