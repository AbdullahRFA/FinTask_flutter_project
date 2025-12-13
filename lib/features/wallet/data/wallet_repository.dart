import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/wallet_model.dart';
import '../../auth/data/auth_repository.dart';

class WalletRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  WalletRepository(this._firestore, this.userId);

  // 1. CREATE WALLET
  Future<void> addWallet({
    required String name,
    required double monthlyBudget,
  }) async {
    try {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc();

      final now = DateTime.now();

      final newWallet = WalletModel(
        id: docRef.id,
        name: name,
        monthlyBudget: monthlyBudget,
        currentBalance: monthlyBudget,
        month: now.month,
        year: now.year,
      );

      await docRef.set(newWallet.toMap());
    } catch (e) {
      throw Exception("Failed to add wallet: $e");
    }
  }

  // 2. GET ALL WALLETS (Stream for Home Screen)
  Stream<List<WalletModel>> getWallets() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .orderBy('year', descending: true)
        .orderBy('month', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return WalletModel.fromMap(doc.data());
      }).toList();
    });
  }

  // 3. GET SINGLE WALLET (Stream for Detail Screen - NEW)
  Stream<WalletModel> getWallet(String walletId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc(walletId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw Exception("Wallet deleted");
      }
      return WalletModel.fromMap(doc.data() as Map<String, dynamic>);
    });
  }
}

// ---------------- PROVIDERS ----------------

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  final user = ref.read(firebaseAuthProvider).currentUser;

  if (user == null) {
    throw Exception("User must be logged in to access WalletRepository");
  }

  return WalletRepository(firestore, user.uid);
});

// For Home Screen List
final walletListProvider = StreamProvider<List<WalletModel>>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWallets();
});

// For Detail Screen Single Wallet (NEW)
final walletStreamProvider = StreamProvider.family<WalletModel, String>((ref, walletId) {
  final repository = ref.watch(walletRepositoryProvider);
  return repository.getWallet(walletId);
});