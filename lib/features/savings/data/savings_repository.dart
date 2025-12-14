import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/savings_goal_model.dart';
import '../../expenses/domain/expense_model.dart';

class SavingsRepository {
  final FirebaseFirestore _firestore;
  final String userId;

  SavingsRepository(this._firestore, this.userId);

  // 1. ADD GOAL
  Future<void> addGoal({
    required String title,
    required double targetAmount,
    required DateTime deadline,
  }) async {
    final docRef = _firestore.collection('users').doc(userId).collection('savings_goals').doc();

    final goal = SavingsGoalModel(
      id: docRef.id,
      title: title,
      targetAmount: targetAmount,
      currentSaved: 0,
      deadline: deadline,
    );

    await docRef.set(goal.toMap());
  }

  // 2. DEPOSIT MONEY
  Future<void> depositToGoal({
    required String walletId,
    required String goalId,
    required String goalTitle,
    required double amount,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(walletId);
      final goalRef = _firestore.collection('users').doc(userId).collection('savings_goals').doc(goalId);
      final expenseRef = walletRef.collection('expenses').doc();

      final walletSnapshot = await transaction.get(walletRef);
      final currentBalance = walletSnapshot.data()?['currentBalance'] ?? 0.0;

      if (currentBalance < amount) {
        throw Exception("Insufficient funds in wallet!");
      }

      transaction.update(walletRef, {
        'currentBalance': FieldValue.increment(-amount),
      });

      transaction.update(goalRef, {
        'currentSaved': FieldValue.increment(amount),
      });

      final depositExpense = ExpenseModel(
        id: expenseRef.id,
        title: "Deposit: $goalTitle",
        amount: amount,
        category: "Savings",
        date: DateTime.now(),
      );
      transaction.set(expenseRef, depositExpense.toMap());
    });
  }

  // 3. GET GOALS
  Stream<List<SavingsGoalModel>> getGoals() {
    return _firestore.collection('users').doc(userId).collection('savings_goals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SavingsGoalModel.fromMap(doc.data())).toList();
    });
  }

  // 4. DELETE GOAL
  Future<void> deleteGoal({required String goalId, String? refundWalletId}) async {
    return _firestore.runTransaction((transaction) async {
      final goalRef = _firestore.collection('users').doc(userId).collection('savings_goals').doc(goalId);

      final goalSnapshot = await transaction.get(goalRef);
      if (!goalSnapshot.exists) return;

      final double savedAmount = (goalSnapshot.data()?['currentSaved'] ?? 0).toDouble();
      final String goalTitle = goalSnapshot.data()?['title'] ?? 'Goal';

      if (savedAmount > 0 && refundWalletId != null) {
        final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(refundWalletId);
        final expenseRef = walletRef.collection('expenses').doc();

        transaction.update(walletRef, {
          'currentBalance': FieldValue.increment(savedAmount),
        });

        final refundExpense = ExpenseModel(
          id: expenseRef.id,
          title: "Refund: $goalTitle",
          amount: -savedAmount,
          category: "Savings",
          date: DateTime.now(),
        );
        transaction.set(expenseRef, refundExpense.toMap());
      }

      transaction.delete(goalRef);
    });
  }
}

// PROVIDERS
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);

  // FIX: Watch authStateProvider
  final authState = ref.watch(authStateProvider);
  final user = authState.value;

  if (user == null) throw Exception("No user");
  return SavingsRepository(firestore, user.uid);
});

final savingsListProvider = StreamProvider<List<SavingsGoalModel>>((ref) {
  return ref.watch(savingsRepositoryProvider).getGoals();
});