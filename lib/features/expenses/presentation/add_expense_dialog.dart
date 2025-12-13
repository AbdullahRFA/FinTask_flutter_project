import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthly_expense_flutter_project/features/expenses/data/expense_repository.dart';
import 'package:monthly_expense_flutter_project/features/expenses/domain/expense_model.dart';

class AddExpenseDialog extends ConsumerStatefulWidget {
  final String walletId;
  final double currentBalance; // <--- NEW: To check limits
  final ExpenseModel? expenseToEdit;

  const AddExpenseDialog({
    super.key,
    required this.walletId,
    required this.currentBalance,
    this.expenseToEdit
  });

  @override
  ConsumerState<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends ConsumerState<AddExpenseDialog> {
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();

  String _selectedCategory = 'Food';
  final List<String> _categories = ['Food', 'Transport', 'Bills', 'Shopping', 'Entertainment', 'Health'];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.expenseToEdit?.title ?? '');
    _amountController = TextEditingController(text: widget.expenseToEdit?.amount.toString() ?? '');
    if (widget.expenseToEdit != null) {
      _selectedCategory = widget.expenseToEdit!.category;
    }
  }

  Future<void> _processTransaction() async {
    setState(() => _isLoading = true);
    try {
      final amount = double.parse(_amountController.text.trim());
      final title = _titleController.text.trim();

      if (widget.expenseToEdit == null) {
        // ADD
        await ref.read(expenseRepositoryProvider).addExpense(
          walletId: widget.walletId,
          title: title,
          amount: amount,
          category: _selectedCategory,
          date: DateTime.now(),
        );
      } else {
        // EDIT
        final newExpense = ExpenseModel(
          id: widget.expenseToEdit!.id,
          title: title,
          amount: amount,
          category: _selectedCategory,
          date: widget.expenseToEdit!.date,
        );

        await ref.read(expenseRepositoryProvider).updateExpense(
          walletId: widget.walletId,
          oldExpense: widget.expenseToEdit!,
          newExpense: newExpense,
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkAndSave() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text.trim());

    // Calculate the actual impact on the wallet
    double impact = amount;
    if (widget.expenseToEdit != null) {
      // If editing, we only care about the DIFFERENCE (e.g. changing 100 to 500 = +400 impact)
      impact = amount - widget.expenseToEdit!.amount;
    }

    // CHECK: Is the impact greater than available money?
    if (impact > widget.currentBalance) {
      // SHOW WARNING POPUP
      final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Insufficient Balance", style: TextStyle(color: Colors.red)),
          content: Text(
              "You are trying to spend ৳$amount but you only have ৳${widget.currentBalance}.\n\n"
                  "This will result in a negative balance. Continue?"
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false), // No
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true), // Yes
              child: const Text("Proceed Anyway"),
            ),
          ],
        ),
      );

      // If user clicked Cancel (false) or clicked outside (null), stop.
      if (confirm != true) return;
    }

    // If check passed or user confirmed, proceed.
    await _processTransaction();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.expenseToEdit == null ? "Add New Expense" : "Edit Expense"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: "Item Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: "Amount"),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
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
          onPressed: _isLoading ? null : _checkAndSave, // Point to our new check function
          child: _isLoading ? const CircularProgressIndicator() : Text(widget.expenseToEdit == null ? "Add" : "Update"),
        ),
      ],
    );
  }
}