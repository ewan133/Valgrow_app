import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/store_profile.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/services/notifs/notification_service.dart';

class ManagementDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final NotificationService _notif = NotificationService();

  /// ✅ **Fetch all employees affiliated with a store (excluding the owner)**
  Future<List<UserProfile>> getEmployeesByStoreId(String storeId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('users')
          .where('storeId', isEqualTo: storeId) // ✅ Filter by store ID
          .where('role', isNotEqualTo: 'Store Owner') // ✅ Exclude store owner
          .get();

      List<UserProfile> employees = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        return UserProfile.fromMap({
          ...data,
          'uid':
              doc.id, // ✅ Explicitly include the Firestore document ID as uid
        });
      }).toList();

      print("✅ Found ${employees.length} employees for store: $storeId");
      return employees; // ✅ Return the list of employees
    } catch (e) {
      print("❌ Error fetching employees for storeId $storeId: $e");
      return []; // Return an empty list if an error occurs
    }
  }

  /// ✅ **Update a specific permission for an employee**
  Future<void> updateEmployeePermission({
    required String userId,
    required String permissionField, // "pos", "ims", "debts", "reports"
    required bool newValue,
  }) async {
    try {
      // Reference the user document
      DocumentReference userRef = _db.collection('users').doc(userId);

      // Update the specific permission field
      await userRef.update({permissionField: newValue});

      print("✅ Updated $permissionField for user $userId → $newValue");
    } catch (e) {
      print("❌ Error updating $permissionField for user $userId: $e");
    }
  }

  /// ✅ Remove an employee from a store (Unassign storeId & reset permissions)
  Future<void> removeEmployeeFromStore(String userId) async {
    try {
      DocumentReference userRef = _db.collection('users').doc(userId);

      await userRef.update({
        'storeId': '', // ✅ Remove the store affiliation
        'role': 'Unassigned', // ✅ Optionally change role
        'pos': true, // ✅ Default permissions
        'ims': false,
        'debts': true,
        'expenses': false,
        'reports': false,
      });

      print(
          "✅ Employee $userId has been removed from the store and permissions reset.");
    } catch (e) {
      print("❌ Error removing employee $userId from store: $e");
    }
  }

  /// ✅ **Fetch store details using storeCode**
  Future<StoreProfile?> getStoreByCode(String storeCode) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('stores')
          .where('storeCode', isEqualTo: storeCode)
          .limit(1) // ✅ Limit to one result
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("❌ No store found with code: $storeCode");
        return null;
      }

      // ✅ Convert Firestore data into StoreProfile model
      var storeData = querySnapshot.docs.first.data() as Map<String, dynamic>;
      return StoreProfile.fromMap({
        ...storeData,
        'storeId': querySnapshot.docs.first.id, // ✅ Assign Firestore doc ID
      });
    } catch (e) {
      print("❌ Error fetching store by code $storeCode: $e");
      return null;
    }
  }

  /// ✅ **Affiliate an employee to a store and notify the owner**
  Future<void> affiliateEmployeeAsEmployee({
    required String userId,
    required String storeId,
    required String employeeName, // ✅ Employee name for notification
    required String ownerId, // ✅ Store owner's ID for notification
  }) async {
    try {
      DocumentReference userRef = _db.collection('users').doc(userId);

      await userRef.update({
        'storeId': storeId, // ✅ Assign the employee to the store
        'role': 'Employee', // ✅ Set role to Employee
        'pos': true, // ✅ Default permissions
        'ims': false,
        'debts': true,
        'expenses': false,
        'reports': false,
      });

      print("✅ Employee $userId affiliated with store $storeId as Employee.");
    } catch (e) {
      print("❌ Error affiliating employee: $e");
    }
  }

  /// ✅ **Add notification for store owner when a new employee joins**
  Future<void> addEmployeeNotification(
    String ownerId,
    String storeId,
    String employeeName,
  ) async {
    try {
      print(
          "ℹ️ Adding Notification: Store Owner: $ownerId, Store ID: $storeId, Employee: $employeeName");

      if (ownerId.isEmpty || storeId.isEmpty || employeeName.isEmpty) {
        print("❌ Error: Missing required fields for notification.");
        return;
      }

      // ✅ Save notification to Firestore
      await _db.collection('notifications').add({
        "storeId": storeId,
        "userId": ownerId, // Store owner's ID
        "title": "New Employee Added",
        "message": "$employeeName has joined your store as an Employee.",
        "icon": "person",
        "isUnread": true,
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Notification successfully added for owner: $ownerId");
    } catch (e) {
      print("❌ Error adding employee notification: $e");
    }
  }

  
}
