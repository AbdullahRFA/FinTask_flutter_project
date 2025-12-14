import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/expense_model.dart';

class ExpenseRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  ExpenseRepository(this._firestore, this.userId);

  // 1. ADD EXPENSE
  Future<void> addExpense({
    required String walletId,
    required String title,
    required double amount,
    required String category,
    required DateTime date,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final walletRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('wallets')
          .doc(walletId);

      final expenseRef = walletRef.collection('expenses').doc();

      final walletSnapshot = await transaction.get(walletRef);
      if (!walletSnapshot.exists) {
        throw Exception("Wallet does not exist!");
      }

      final currentBalance = walletSnapshot.data()?['currentBalance'] ?? 0.0;

      final newExpense = ExpenseModel(
        id: expenseRef.id,
        title: title,
        amount: amount,
        category: category,
        date: date,
      );

      transaction.set(expenseRef, newExpense.toMap());

      transaction.update(walletRef, {
        'currentBalance': currentBalance - amount,
      });
    });
  }

  // 2. GET EXPENSES
  Stream<List<ExpenseModel>> getExpenses(String walletId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('wallets')
        .doc(walletId)
        .collection('expenses')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ExpenseModel.fromMap(doc.data());
      }).toList();
    });
  }

  // 3. DELETE EXPENSE
  Future<void> deleteExpense({
    required String walletId,
    required String expenseId,
    required double amount
  }) async {
    return _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(walletId);
      final expenseRef = walletRef.collection('expenses').doc(expenseId);

      transaction.update(walletRef, {
        'currentBalance': FieldValue.increment(amount)
      });

      transaction.delete(expenseRef);
    });
  }

  // 4. EDIT EXPENSE
  Future<void> updateExpense({
    required String walletId,
    required ExpenseModel oldExpense,
    required ExpenseModel newExpense,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(walletId);
      final expenseRef = walletRef.collection('expenses').doc(oldExpense.id);

      final difference = oldExpense.amount - newExpense.amount;

      transaction.update(expenseRef, newExpense.toMap());

      if (difference != 0) {
        transaction.update(walletRef, {
          'currentBalance': FieldValue.increment(difference),
        });
      }
    });
  }
}

// ---------------- PROVIDERS ----------------

final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);

  // FIX: Watch authStateProvider
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) throw Exception("No user logged in");

  return ExpenseRepository(firestore, user.uid);
});

final expenseListProvider = StreamProvider.family<List<ExpenseModel>, String>((ref, walletId) {
  final repo = ref.watch(expenseRepositoryProvider);
  return repo.getExpenses(walletId);
});