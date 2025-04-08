import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/expenses_details.dart';

class ExpensesDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ✅ Add a new expense to Firestore
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _firestore.collection('expenses').add(expense.toMap());

      print("✅ Expense added successfully");
    } catch (e) {
      print("❌ Failed to add expense: $e");
      rethrow;
    }
  }

  /// ✅ Fetch expenses for a specific store
  Future<List<ExpenseModel>> getExpensesByStoreId(String storeId) async {
    try {
      final snapshot = await _firestore
          .collection('expenses')
          .where('storeId', isEqualTo: storeId)
          .orderBy('date', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => ExpenseModel.fromDocument(doc))
          .toList();
    } catch (e) {
      print("❌ Error fetching expenses for store $storeId: $e");
      return [];
    }
  }

  /// ✅ Update an existing expense by document ID
  Future<void> updateExpense({
    required String expenseId,
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) async {
    try {
      final expenseRef = _firestore.collection('expenses').doc(expenseId);

      final Map<String, dynamic> updates = {};

      if (amount != null) updates['amount'] = amount;
      if (category != null) updates['category'] = category;
      if (date != null) updates['date'] = Timestamp.fromDate(date);
      if (note != null) updates['note'] = note;

      if (updates.isEmpty) {
        print("⚠️ No updates provided for expense $expenseId.");
        return;
      }

      await expenseRef.update(updates);

      print("✅ Expense $expenseId updated successfully.");
    } catch (e) {
      print("❌ Failed to update expense $expenseId: $e");
      rethrow;
    }
  }

  /// ✅ Delete an expense by its document ID
  Future<void> deleteExpense(String expenseId) async {
    try {
      final expenseRef = _firestore.collection('expenses').doc(expenseId);

      await expenseRef.delete();

      print("🗑️ Expense $expenseId deleted successfully.");
    } catch (e) {
      print("❌ Failed to delete expense $expenseId: $e");
      rethrow;
    }
  }
}
