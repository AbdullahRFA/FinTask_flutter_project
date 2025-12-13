import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// CORRECTED IMPORTS: Using full package paths
import 'package:monthly_expense_flutter_project/features/auth/data/auth_repository.dart';
import 'package:monthly_expense_flutter_project/features/wallet/data/wallet_repository.dart';
import 'package:monthly_expense_flutter_project/features/wallet/presentation/add_wallet_dialog.dart';
import 'package:monthly_expense_flutter_project/features/wallet/presentation/wallet_detail_screen.dart';

import '../../core/utils/currency_helper.dart';
import 'package:monthly_expense_flutter_project/features/settings/presentation/settings_screen.dart';
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the wallet list (Real-time!)
    final walletListAsync = ref.watch(walletListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wallets"),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.logout),
          //   onPressed: () {
          //     // Read the repository and sign out
          //     ref.read(authRepositoryProvider).signOut();
          //   },
          // ),
        ],
      ),
      // NEW: Add the Drawer
      drawer: Drawer(
        child: Column(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.teal),
              child: Center(
                child: Text(
                  "Monthly Expense",
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pop(context); // Close drawer first
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));
              },
            ),
            const Spacer(), // Pushes logout to bottom
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {
                ref.read(authRepositoryProvider).signOut();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (_) => const AddWalletDialog()
          );
        },
        child: const Icon(Icons.add),
      ),
      body: walletListAsync.when(
        data: (wallets) {
          if (wallets.isEmpty) {
            return const Center(child: Text("No wallets yet. Create one!"));
          }
          return ListView.builder(
            itemCount: wallets.length,
            itemBuilder: (context, index) {
              final wallet = wallets[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(wallet.name),
                  subtitle: Text("Budget: ${wallet.monthlyBudget}"),
                  trailing: Text(
                    "Bal: ${CurrencyHelper.format(wallet.currentBalance)}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                      fontSize: 16,
                    ),
                  ),
                  // NEW: Add Navigation
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WalletDetailScreen(wallet: wallet),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),

        // --- UPDATED ERROR HANDLING ---
        error: (err, stack) {
          // 1. This prints the error to your VS Code / Terminal Console
          debugPrint("========================================");
          debugPrint("ERROR LOADING WALLETS: $err");
          debugPrint("STACK TRACE: $stack");
          debugPrint("========================================");

          // 2. This shows it on the screen
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text("Error: $err", textAlign: TextAlign.center),
            ),
          );
        },
      ),
    );
  }
}