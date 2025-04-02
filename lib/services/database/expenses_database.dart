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
  
}
