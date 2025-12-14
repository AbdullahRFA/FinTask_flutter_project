import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monthly_expense_flutter_project/features/wallet/data/wallet_repository.dart';
import 'package:monthly_expense_flutter_project/features/wallet/domain/wallet_model.dart';
import 'package:monthly_expense_flutter_project/core/utils/currency_helper.dart';
import '../../providers/theme_provider.dart'; // Import Theme

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

    // THEME COLORS
    final isDark = ref.watch(themeProvider);
    final dialogColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    // FIX: Ensure non-nullable Colors
    final Color inputFill = isDark ? const Color(0xFF2C2C2C) : (Colors.grey[50] ?? Colors.white);
    final Color borderColor = isDark ? (Colors.grey[800] ?? Colors.grey) : (Colors.grey[200] ?? Colors.grey);

    return Dialog(
      backgroundColor: dialogColor,
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
                        color: Colors.teal.withOpacity(isDark ? 0.2 : 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(isEdit ? Icons.edit_note_rounded : Icons.account_balance_wallet_rounded, color: Colors.teal),
                    ),
                    const SizedBox(width: 15),
                    Text(
                      isEdit ? "Edit Wallet" : "New Budget",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textColor),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Name Input
                TextFormField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration("Wallet Name", "e.g., October 2025", Icons.label_outline, isDark, inputFill, borderColor),
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 16),

                // Budget Input
                TextFormField(
                  controller: _amountController,
                  style: TextStyle(color: textColor),
                  decoration: _buildInputDecoration("Monthly Limit", "e.g., 25000", Icons.attach_money, isDark, inputFill, borderColor),
                  keyboardType: TextInputType.number,
                  validator: (val) => val!.isEmpty ? "Required" : null,
                ),
                const SizedBox(height: 24),

                // Rollover Section
                if (!isEdit) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF253035) : Colors.blueGrey.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.transparent : Colors.blueGrey.shade100),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.history_edu_rounded, size: 18, color: isDark ? Colors.blueGrey.shade200 : Colors.blueGrey.shade700),
                            const SizedBox(width: 8),
                            Text("Rollover Balance", style: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.blueGrey.shade100 : Colors.blueGrey.shade800)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Carry over leftover cash from a previous wallet to start with a surplus.",
                          style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey),
                        ),
                        const SizedBox(height: 12),

                        walletListAsync.when(
                          data: (wallets) {
                            if (wallets.isEmpty) return Text("No previous wallets found.", style: TextStyle(fontSize: 12, color: isDark ? Colors.grey : Colors.grey));
                            return DropdownButtonFormField<String>(
                              value: _selectedRolloverWalletId,
                              isExpanded: true,
                              dropdownColor: dialogColor,
                              style: TextStyle(color: textColor),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                                hintText: "Select previous wallet",
                                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                              ),
                              items: wallets.map((w) {
                                return DropdownMenuItem(
                                  value: w.id,
                                  child: Text(
                                    "${w.name} (${CurrencyHelper.format(w.currentBalance)})",
                                    style: TextStyle(fontSize: 13, color: textColor),
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
                          Divider(color: isDark ? Colors.grey[700] : Colors.grey[300]),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Starting Balance:", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: textColor)),
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
                      child: Text("Cancel", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
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

  InputDecoration _buildInputDecoration(String label, String hint, IconData icon, bool isDark, Color fill, Color border) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
      hintText: hint,
      hintStyle: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[400]),
      prefixIcon: Icon(icon, color: isDark ? Colors.grey[400] : Colors.grey),
      filled: true,
      fillColor: fill,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: border)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.teal, width: 2)),
    );
  }
}