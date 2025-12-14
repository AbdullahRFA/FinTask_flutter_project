import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/savings_repository.dart';

class AddGoalDialog extends ConsumerStatefulWidget {
  const AddGoalDialog({super.key});

  @override
  ConsumerState<AddGoalDialog> createState() => _AddGoalDialogState();
}

class _AddGoalDialogState extends ConsumerState<AddGoalDialog> {
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  Future<void> _save() async {
    if (_titleController.text.isEmpty || _amountController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(savingsRepositoryProvider).addGoal(
        title: _titleController.text.trim(),
        targetAmount: double.parse(_amountController.text.trim()),
        deadline: _selectedDate,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("New Savings Goal"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: "Goal Name (e.g. Laptop)"),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: "Target Amount"),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text("Deadline: ${DateFormat('MMM d, y').format(_selectedDate)}"),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: const Text("Change"),
              )
            ],
          )
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(onPressed: _isLoading ? null : _save, child: const Text("Create Goal")),
      ],
    );
  }
}