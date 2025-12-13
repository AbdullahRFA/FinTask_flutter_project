import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthly_expense_flutter_project/features/expenses/data/expense_repository.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  final String walletId; // We need to know WHICH wallet to charge

  const AddExpenseDialog({super.key, required this.walletId});

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Default category
  String _selectedCategory = 'Food';

  // Hardcoded categories for now (MVP)
  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Shopping', 'Entertainment', 'Health'];

  bool _isLoading = false;

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountController.text.trim());

      // Call the Repository
      await ref.read(expenseRepositoryProvider).addExpense(
        walletId: widget.walletId,
        title: _titleController.text.trim(),
        amount: amount,
        category: _selectedCategory,
        date: DateTime.now(), // Default to Right Now
        //   date: DateTime.now().subtract(const Duration(days: 1))

      );

      if (mounted) Navigator.pop(context); // Close dialog

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add New Expense"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Item Name (e.g. Burger)"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
                decoration: const InputDecoration(labelText: "Category"),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveExpense,
          child: _isLoading ? const CircularProgressIndicator() : const Text("Add"),
        ),
      ],
    );
  }
}