import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  ExpenseRepository(this._firestore, this.userId);

  // 1. ADD EXPENSE (Atomic Transaction)
  Future<void> addExpense({
    required String walletId,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
  }) async {
    // We start a "Transaction". Firestore locks the wallet document while we work.
    return _firestore.runTransaction((transaction) async {
      // A. Reference to the Wallet Document
      final walletRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(walletId);

      // B. Reference for the new Expense Document
      final expenseRef = walletRef.collection('expenses').doc();

      // C. Read the current wallet data FIRST
      final walletSnapshot = await transaction.get(walletRef);
      if (!walletSnapshot.exists) {
        throw Exception("Wallet does not exist!");
      }

      final currentBalance = walletSnapshot.data()?['currentBalance'] ?? 0.0;

      // D. Create the Expense Object
      final newExpense = ExpenseModel(
        id: expenseRef.id,
        title: title,
        amount: amount,
        category: category,
        date: date,
      );

      // E. WRITE 1: Save the Expense
      transaction.set(expenseRef, newExpense.toMap());

      // F. WRITE 2: Update the Wallet Balance
      transaction.update(walletRef, {
        'currentBalance': currentBalance - amount,
      });
    });
  }

  // 2. GET EXPENSES (Stream)
  Stream<List<ExpenseModel>> getExpenses(String walletId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc(walletId)
        .collection('expenses')
        .orderBy('date', descending: true) // Newest first
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data());
      }).toList();
    });
  }

  // 3. DELETE EXPENSE (Atomic Transaction - Restore Balance)
  Future<void> deleteExpense({
    required String walletId,
    required String expenseId,
    required double amount
  }) async {
    return _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(walletId);
      final expenseRef = walletRef.collection('expenses').doc(expenseId);

      // Restore the money to the wallet
      transaction.update(walletRef, {
        'currentBalance': FieldValue.increment(amount) // Atomic increment
      });

      // Delete the expense
      transaction.delete(expenseRef);
    });
  }
}

// ---------------- PROVIDERS ----------------

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  final user = ref.read(firebaseAuthProvider).currentUser;

  if (user == null) throw Exception("No user logged in");

  return ExpenseRepository(firestore, user.uid);
});

// We use 'family' because we need an input (walletId) to get the stream
final expenseListProvider = StreamProvider.family<List<ExpenseModel>, String>((ref, walletId) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpenses(walletId);
});