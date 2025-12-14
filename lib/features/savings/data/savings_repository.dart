import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/savings_goal_model.dart';
import '../../expenses/domain/expense_model.dart'; // Import Expense Model

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

  // 2. DEPOSIT MONEY (Transfer from Wallet -> Savings)
  // Modified to add an "Expense" record to the wallet
  Future<void> depositToGoal({
    required String walletId,
    required String goalId,
    required String goalTitle, // <--- NEW: Need title for the expense name
    required double amount,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(walletId);
      final goalRef = _firestore.collection('users').doc(userId).collection('savings_goals').doc(goalId);
      final expenseRef = walletRef.collection('expenses').doc(); // New Expense Doc

      // Check Wallet Balance
      final walletSnapshot = await transaction.get(walletRef);
      final currentBalance = walletSnapshot.data()?['currentBalance'] ?? 0.0;

      if (currentBalance < amount) {
        throw Exception("Insufficient funds in wallet!");
      }

      // 1. Deduct from Wallet Balance
      transaction.update(walletRef, {
        'currentBalance': FieldValue.increment(-amount),
      });

      // 2. Add to Goal
      transaction.update(goalRef, {
        'currentSaved': FieldValue.increment(amount),
      });

      // 3. CREATE EXPENSE RECORD (So user sees where money went)
      final depositExpense = ExpenseModel(
        id: expenseRef.id,
        title: "Deposit: $goalTitle",
        amount: amount,
        category: "Savings", // Special Category
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

  // 4. DELETE GOAL (With Refund & Income Record)
  Future<void> deleteGoal({required String goalId, String? refundWalletId}) async {
    return _firestore.runTransaction((transaction) async {
      final goalRef = _firestore.collection('users').doc(userId).collection('savings_goals').doc(goalId);

      // Read the goal first
      final goalSnapshot = await transaction.get(goalRef);
      if (!goalSnapshot.exists) return;

      final double savedAmount = (goalSnapshot.data()?['currentSaved'] ?? 0).toDouble();
      final String goalTitle = goalSnapshot.data()?['title'] ?? 'Goal';

      // If money exists and we have a wallet to refund to
      if (savedAmount > 0 && refundWalletId != null) {
        final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(refundWalletId);
        final expenseRef = walletRef.collection('expenses').doc();

        // 1. Refund the Balance
        transaction.update(walletRef, {
          'currentBalance': FieldValue.increment(savedAmount),
        });

        // 2. CREATE REFUND RECORD (Negative Expense = Income)
        // We use a negative amount so it stands out, or you can use positive and handle it differently.
        // Standard logic: If I delete this "Negative Expense" later, it will SUBTRACT money, which is correct.
        final refundExpense = ExpenseModel(
          id: expenseRef.id,
          title: "Refund: $goalTitle",
          amount: -savedAmount, // Negative amount indicates money coming back
          category: "Savings",
          date: DateTime.now(),
        );
        transaction.set(expenseRef, refundExpense.toMap());
      }

      // Delete the goal
      transaction.delete(goalRef);
    });
  }
}

// PROVIDERS
final savingsRepositoryProvider = Provider<SavingsRepository>((ref) {
  final firestore = ref.read(firebaseFirestoreProvider);
  final user = ref.read(firebaseAuthProvider).currentUser;
  if (user == null) throw Exception("No user");
  return SavingsRepository(firestore, user.uid);
});

final savingsListProvider = StreamProvider<List<SavingsGoalModel>>((ref) {
  return ref.watch(savingsRepositoryProvider).getGoals();
});