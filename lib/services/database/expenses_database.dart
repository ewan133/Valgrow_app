import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/expenses_details.dart';
import 'package:valgrow_ui/services/database/audit_database.dart';

class ExpensesDatabase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuditDatabase _auditDb = AuditDatabase();

  /// ✅ Add a new expense to Firestore
  Future<void> addExpense(ExpenseModel expense) async {
    try {
      final docRef =
          await _firestore.collection('expenses').add(expense.toMap());

      // ✅ Log audit trail
      await _auditDb.logAudit(
        storeId: expense.storeId,
        userId: expense.userId ??
            expense.storeId, // ✅ Use actual userId or fallback to storeId
        action: 'CREATE_EXPENSE',
        entityType: 'expense',
        entityId: docRef.id,
        description:
            'Expense added: ${expense.category} - ₱${expense.amount.toStringAsFixed(2)}',
        metadata: {
          'amount': expense.amount,
          'category': expense.category,
          'note': expense.note,
          'date': expense.date.toIso8601String(),
        },
      );

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
    required String userId, // ✅ Added userId to track who updated
    double? amount,
    String? category,
    DateTime? date,
    String? note,
  }) async {
    try {
      final expenseRef = _firestore.collection('expenses').doc(expenseId);

      // Get old data for audit log
      final expenseDoc = await expenseRef.get();
      final oldData = expenseDoc.data();

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

      // ✅ Log audit trail
      if (oldData != null) {
        await _auditDb.logAudit(
          storeId: oldData['storeId'] ?? '',
          userId: userId,
          action: 'UPDATE_EXPENSE',
          entityType: 'expense',
          entityId: expenseId,
          description: 'Expense updated: ${category ?? oldData['category']}',
          metadata: {
            'updatedFields': updates.keys.toList(),
            'oldAmount': oldData['amount'],
            'newAmount': amount,
            'category': category ?? oldData['category'],
          },
        );
      }

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

      // Get expense data before deleting for audit log
      final expenseDoc = await expenseRef.get();
      final expenseData = expenseDoc.data();

      await expenseRef.delete();

      // ✅ Log audit trail
      if (expenseData != null) {
        await _auditDb.logAudit(
          storeId: expenseData['storeId'] ?? '',
          userId: expenseData['userId'] ??
              expenseData['storeId'] ??
              '', // ✅ Use actual userId
          action: 'DELETE_EXPENSE',
          entityType: 'expense',
          entityId: expenseId,
          description:
              'Expense deleted: ${expenseData['category']} - ₱${expenseData['amount']}',
          metadata: {
            'amount': expenseData['amount'],
            'category': expenseData['category'],
            'note': expenseData['note'] ?? '',
          },
        );
      }

      print("🗑️ Expense $expenseId deleted successfully");
    } catch (e) {
      print("❌ Failed to delete expense $expenseId: $e");
      rethrow;
    }
  }
}
