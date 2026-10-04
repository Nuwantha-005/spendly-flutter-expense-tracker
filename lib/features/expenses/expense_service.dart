import 'package:cloud_firestore/cloud_firestore.dart';
import 'models/expense.dart';

/// Service responsible for performing Cloud Firestore CRUD operations for user expenses.
/// All expenses are strictly scoped to `users/{userId}/expenses/{expenseId}`.
class ExpenseService {
  ExpenseService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// Returns the sub-collection reference for a specific user's expenses.
  CollectionReference<Map<String, dynamic>> _userExpensesRef(String userId) {
    return _firestore.collection('users').doc(userId).collection('expenses');
  }

  /// Adds a new expense to Firestore under `users/{userId}/expenses/{expenseId}`.
  Future<void> addExpense({
    required String userId,
    required Expense expense,
  }) async {
    final collection = _userExpensesRef(userId);
    final docRef = expense.id.isNotEmpty ? collection.doc(expense.id) : collection.doc();
    await docRef.set(expense.copyWith(id: docRef.id).toFirestore());
  }

  /// Fetches a one-time list of expenses for the given user, ordered by date descending.
  Future<List<Expense>> getExpenses(String userId) async {
    final snapshot = await _userExpensesRef(userId)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
  }

  /// Streams real-time expenses for the given user, ordered by date descending.
  Stream<List<Expense>> watchExpenses(String userId) {
    return _userExpensesRef(userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList());
  }

  /// Updates an existing expense document in Firestore.
  Future<void> updateExpense({
    required String userId,
    required Expense expense,
  }) async {
    if (expense.id.isEmpty) {
      throw ArgumentError('Cannot update an expense without a valid document ID.');
    }
    await _userExpensesRef(userId).doc(expense.id).set(
          expense.toFirestore(),
          SetOptions(merge: true),
        );
  }

  /// Deletes an expense document from Firestore.
  Future<void> deleteExpense({
    required String userId,
    required String expenseId,
  }) async {
    if (expenseId.isEmpty) {
      throw ArgumentError('Cannot delete an expense without a valid document ID.');
    }
    await _userExpensesRef(userId).doc(expenseId).delete();
  }
}
