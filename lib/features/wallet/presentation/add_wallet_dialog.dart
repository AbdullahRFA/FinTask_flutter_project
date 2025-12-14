import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthly_expense_flutter_project/features/wallet/data/wallet_repository.dart';
import 'package:monthly_expense_flutter_project/features/wallet/domain/wallet_model.dart';
import 'package:monthly_expense_flutter_project/core/utils/currency_helper.dart';

class AddWalletDialog extends ConsumerStatefulWidget {
  final WalletModel? walletToEdit;

  const AddWalletDialog({super.key, this.walletToEdit});

  @override
  ConsumerState<AddWalletDialog> createState() => _AddWalletDialogState();
}

class _AddWalletDialogState extends ConsumerState<AddWalletDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String? _selectedRolloverWalletId;
  String? _selectedRolloverWalletName;
  double _rolloverAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.walletToEdit?.name ?? '');
    _amountController = TextEditingController(text: widget.walletToEdit?.monthlyBudget.toString() ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final budget = double.parse(_amountController.text.trim());
      final name = _nameController.text.trim();

      if (widget.walletToEdit == null) {
        await ref.read(walletRepositoryProvider).addWallet(
          name: name,
          monthlyBudget: budget,
          rolloverAmount: _rolloverAmount,
          sourceWalletId: _selectedRolloverWalletId,
          sourceWalletName: _selectedRolloverWalletName,
        );
      } else {
        await ref.read(walletRepositoryProvider).updateWallet(
            oldWallet: widget.walletToEdit!,
            newName: name,
            newBudget: budget
        );
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final walletListAsync = ref.watch(walletListProvider);
    final isEdit = widget.walletToEdit != null;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isEdit ? Icons.edit_note_rounded : Icons.account_balance_wallet_rounded, color: Colors.teal),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      isEdit ? "Edit Wallet" : "New Budget",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: _buildInputDecoration("Wallet Name", "e.g., October 2025", Icons.label_outline),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                // Budget Input
                TextFormField(
                  controller: _amountController,
                  decoration: _buildInputDecoration("Monthly Limit", "e.g., 25000", Icons.attach_money),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 24),

                // Rollover Section (Only for New Wallets)
                if (!isEdit) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blueGrey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_edu_rounded, size: 18, color: Colors.blueGrey.shade700),
                            const SizedBox(width: 8),
                            Text("Rollover Balance", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey.shade800)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Carry over leftover cash from a previous wallet to start with a surplus.",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(height: 12),

                        walletListAsync.when(
                          data: (wallets) {
                            if (wallets.isEmpty) return const Text("No previous wallets found.", style: TextStyle(fontSize: 12, color: Colors.grey));
                            return DropdownButtonFormField<String>(
                              value: _selectedRolloverWalletId,
                              isExpanded: true,
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: Colors.white,
                                hintText: "Select previous wallet",
                                hintStyle: const TextStyle(fontSize: 13),
                              ),
                              items: wallets.map((w) {
                                return DropdownMenuItem(
                                  value: w.id,
                                  child: Text(
                                    "${w.name} (${CurrencyHelper.format(w.currentBalance)})",
                                    style: const TextStyle(fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedRolloverWalletId = val;
                                  final selectedWallet = wallets.firstWhere((w) => w.id == val);
                                  _selectedRolloverWalletName = selectedWallet.name;
                                  _rolloverAmount = selectedWallet.currentBalance;
                                });
                              },
                            );
                          },
                          loading: () => const LinearProgressIndicator(),
                          error: (e, s) => const SizedBox(),
                        ),

                        if (_selectedRolloverWalletId != null) ...[
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Starting Balance:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              Text(
                                CurrencyHelper.format((double.tryParse(_amountController.text) ?? 0) + _rolloverAmount),
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                              ),
                            ],
                          ),
                        ]
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text("Cancel", style: TextStyle(color: Colors.grey[600])),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? "Save Changes" : "Create Wallet"),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
    );
  }
}