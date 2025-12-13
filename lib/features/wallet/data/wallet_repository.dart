import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/wallet_model.dart';
import '../../auth/data/auth_repository.dart'; // To get the User ID

class WalletRepository {
  final FirebaseFirestore _firestore;
  final String userId; // We need to know WHOSE wallets to fetch

  WalletRepository(this._firestore, this.userId);

  // 1. CREATE WALLET
  Future<void> addWallet({
    required String name,
    required double monthlyBudget,
  }) async {
    try {
      // Create a reference for a new document ID
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(); // Empty .doc() generates a random ID

      final now = DateTime.now();

      final newWallet = WalletModel(
        id: docRef.id, // Use the generated ID
        name: name,
        monthlyBudget: monthlyBudget,
        currentBalance: monthlyBudget, // Initially, balance = budget
        month: now.month,
        year: now.year,
      );

      // Save to Firestore
      await docRef.set(newWallet.toMap());

    } catch (e) {
      throw Exception("Failed to add wallet: $e");
    }
  }

  // 2. GET WALLETS (Real-time Stream)
  // Instead of Future (one-time), we use Stream (continuous connection).
  // If you change data in the Console, the App updates INSTANTLY.
  Stream<List<WalletModel>> getWallets() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .orderBy('year', descending: true) // Show newest first
        .orderBy('month', descending: true)
        .snapshots() // This opens the live connection
        .map((snapshot) {
      // Convert the "Snapshot" (JSON) to a List of WalletModel
      return snapshot.docs.map((doc) {
        return WalletModel.fromMap(doc.data());
      }).toList();
    });
  }
}

// ---------------- PROVIDERS ----------------

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  // Get the current user ID from the Auth provider
  final user = ref.read(firebaseAuthProvider).currentUser;

  if (user == null) {
    throw Exception("User must be logged in to access WalletRepository");
  }

  return WalletRepository(firestore, user.uid);
});

// A convenient provider to get the list of wallets in the UI
final walletListProvider = StreamProvider<List<WalletModel>>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWallets();
});