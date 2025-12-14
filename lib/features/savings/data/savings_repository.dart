import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/data/auth_repository.dart';
import '../domain/savings_goal_model.dart';

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
      currentSaved: 0, // Starts at 0
      deadline: deadline,
    );

    await docRef.set(goal.toMap());
  }

  // 2. DEPOSIT MONEY (Transfer from Wallet -> Savings)
  Future<void> depositToGoal({
    required String walletId,
    required String goalId,
    required double amount,
  }) async {
    return _firestore.runTransaction((transaction) async {
      final walletRef = _firestore.collection('users').doc(userId).collection('wallets').doc(walletId);
      final goalRef = _firestore.collection('users').doc(userId).collection('savings_goals').doc(goalId);

      // Check Wallet Balance
      final walletSnapshot = await transaction.get(walletRef);
      final currentBalance = walletSnapshot.data()?['currentBalance'] ?? 0.0;

      if (currentBalance < amount) {
        throw Exception("Insufficient funds in wallet!");
      }

      // Deduct from Wallet
      transaction.update(walletRef, {
        'currentBalance': FieldValue.increment(-amount),
      });

      // Add to Goal
      transaction.update(goalRef, {
        'currentSaved': FieldValue.increment(amount),
      });
    });
  }

  // 3. GET GOALS
  Stream<List<SavingsGoalModel>> getGoals() {
    return _firestore.collection('users').doc(userId).collection('savings_goals').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SavingsGoalModel.fromMap(doc.data())).toList();
    });
  }

  // 4. DELETE GOAL
  Future<void> deleteGoal(String goalId) async {
    await _firestore.collection('users').doc(userId).collection('savings_goals').doc(goalId).delete();
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