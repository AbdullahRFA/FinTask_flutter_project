import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/data/wallet_repository.dart';
import '../../wallet/domain/wallet_model.dart';
import '../data/savings_repository.dart';

class DepositDialog extends ConsumerStatefulWidget {
  final String goalId;
  final String goalTitle;

  const DepositDialog({super.key, required this.goalId, required this.goalTitle});

  @override
  ConsumerState<DepositDialog> createState() => _DepositDialogState();
}

class _DepositDialogState extends ConsumerState<DepositDialog> {
  String? _selectedWalletId;
  final _amountController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final walletsAsync = ref.watch(walletListProvider);

    return AlertDialog(
      title: Text("Deposit to ${widget.goalTitle}"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Select Source Wallet
          walletsAsync.when(
            data: (wallets) {
              if (wallets.isEmpty) return const Text("No wallets available.");
              return DropdownButtonFormField<String>(
                value: _selectedWalletId,
                hint: const Text("Select Source Wallet"),
                isExpanded: true,
                items: wallets.map((w) {
                  return DropdownMenuItem(
                    value: w.id,
                    child: Text("${w.name} (Bal: ${w.currentBalance})"),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedWalletId = val),
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (e, s) => Text("Error: $e"),
          ),
          const SizedBox(height: 10),

          // 2. Amount Input
          TextField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: "Amount to Transfer"),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
        ElevatedButton(
          // ... inside ElevatedButton ...
          onPressed: _isLoading ? null : () async {
            if (_selectedWalletId == null || _amountController.text.isEmpty) return;
            setState(() => _isLoading = true);
            try {
              await ref.read(savingsRepositoryProvider).depositToGoal(
                walletId: _selectedWalletId!,
                goalId: widget.goalId,
                goalTitle: widget.goalTitle, // <--- PASS THE TITLE HERE
                amount: double.parse(_amountController.text.trim()),
              );
              if (mounted) Navigator.pop(context);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
            } finally {
              if (mounted) setState(() => _isLoading = false);
            }
          },
          child: const Text("Transfer"),
        ),
      ],
    );
  }
}