import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/wallet_repository.dart';

class AddWalletDialog extends ConsumerStatefulWidget {
  const AddWalletDialog({super.key});

  @override
  ConsumerState<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends ConsumerState<AddWalletDialog> {
  final _nameController = TextEditingController(text: "Main Wallet");
  final _amountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _saveWallet() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final budget = double.parse(_amountController.text.trim());

      await ref.read(walletRepositoryProvider).addWallet(
        name: _nameController.text.trim(),
        monthlyBudget: budget,
      );

      if (mounted) Navigator.pop(context); // Close dialog on success

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Create Monthly Wallet"),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content height
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Wallet Name"),
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: "Budget Amount (BDT)"),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? "Required" : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveWallet,
          child: _isLoading ? const CircularProgressIndicator() : const Text("Create"),
        ),
      ],
    );
  }
}