import 'package:cloud_firestore/cloud_firestore.dart';

class AuditDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Log an audit entry
  Future<void> logAudit({
    required String storeId,
    required String userId,
    required String
        action, // e.g., "CREATE_TRANSACTION", "UPDATE_INVENTORY", "DEBT_PAYMENT"
    required String
        entityType, // e.g., "transaction", "debt", "inventory", "customer"
    required String entityId, // The ID of the affected entity
    required String description, // Human-readable description
    Map<String, dynamic>? metadata, // Additional context data
    String? userName, // Optional: Cache the user's name for faster display
  }) async {
    try {
      // ✅ Fetch userName from Firestore if not provided
      String resolvedUserName = userName ?? await _getUserName(userId);

      final auditRef = _db.collection('audit_trail').doc();

      await auditRef.set({
        'auditId': auditRef.id,
        'storeId': storeId,
        'userId': userId,
        'userName': resolvedUserName,
        'action': action,
        'entityType': entityType,
        'entityId': entityId,
        'description': description,
        'metadata': metadata ?? {},
        'timestamp': FieldValue.serverTimestamp(),
        'ipAddress': null, // Can be populated if tracking IP
        'deviceInfo': null, // Can be populated if tracking device
      });

      print("✅ Audit log created: $action on $entityType ($entityId)");
    } catch (e) {
      print("❌ Error logging audit: $e");
      // Don't throw - audit logging should not break main operations
    }
  }

  /// ✅ Fetch audit trail for a specific store
  Future<List<Map<String, dynamic>>> getAuditTrail({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
    String? userId, // Filter by specific user
    String? entityType, // Filter by entity type
    String? action, // Filter by action type
    int limit = 100,
  }) async {
    try {
      Query query = _db
          .collection('audit_trail')
          .where('storeId', isEqualTo: storeId)
          .orderBy('timestamp', descending: true);

      if (userId != null && userId.isNotEmpty) {
        query = query.where('userId', isEqualTo: userId);
      }

      if (entityType != null && entityType.isNotEmpty) {
        query = query.where('entityType', isEqualTo: entityType);
      }

      if (action != null && action.isNotEmpty) {
        query = query.where('action', isEqualTo: action);
      }

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      query = query.limit(limit);

      QuerySnapshot snapshot = await query.get();

      List<Map<String, dynamic>> auditLogs = snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'auditId': doc.id,
          'storeId': data['storeId'] ?? '',
          'userId': data['userId'] ?? '',
          'userName': data['userName'] ?? 'Unknown',
          'action': data['action'] ?? '',
          'entityType': data['entityType'] ?? '',
          'entityId': data['entityId'] ?? '',
          'description': data['description'] ?? '',
          'metadata': data['metadata'] ?? {},
          'timestamp':
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
          'ipAddress': data['ipAddress'],
          'deviceInfo': data['deviceInfo'],
        };
      }).toList();

      print("✅ Fetched ${auditLogs.length} audit entries for store: $storeId");
      return auditLogs;
    } catch (e) {
      print("❌ Error fetching audit trail: $e");
      return [];
    }
  }

  /// ✅ Stream audit trail for real-time updates
  Stream<List<Map<String, dynamic>>> streamAuditTrail({
    required String storeId,
    int limit = 50,
  }) {
    return _db
        .collection('audit_trail')
        .where('storeId', isEqualTo: storeId)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();
        return {
          'auditId': doc.id,
          'storeId': data['storeId'] ?? '',
          'userId': data['userId'] ?? '',
          'userName': data['userName'] ?? 'Unknown',
          'action': data['action'] ?? '',
          'entityType': data['entityType'] ?? '',
          'entityId': data['entityId'] ?? '',
          'description': data['description'] ?? '',
          'metadata': data['metadata'] ?? {},
          'timestamp':
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    });
  }

  /// ✅ Get audit trail for a specific entity
  Future<List<Map<String, dynamic>>> getEntityAuditHistory({
    required String entityId,
    required String entityType,
  }) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('audit_trail')
          .where('entityId', isEqualTo: entityId)
          .where('entityType', isEqualTo: entityType)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'auditId': doc.id,
          'userId': data['userId'] ?? '',
          'userName': data['userName'] ?? 'Unknown',
          'action': data['action'] ?? '',
          'description': data['description'] ?? '',
          'metadata': data['metadata'] ?? {},
          'timestamp':
              (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        };
      }).toList();
    } catch (e) {
      print("❌ Error fetching entity audit history: $e");
      return [];
    }
  }

  /// ✅ Get user activity summary
  Future<Map<String, dynamic>> getUserActivitySummary({
    required String storeId,
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _db
          .collection('audit_trail')
          .where('storeId', isEqualTo: storeId)
          .where('userId', isEqualTo: userId);

      if (startDate != null) {
        query = query.where('timestamp',
            isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      if (endDate != null) {
        query = query.where('timestamp',
            isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      QuerySnapshot snapshot = await query.get();

      Map<String, int> actionCounts = {};
      Map<String, int> entityTypeCounts = {};

      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        String action = data['action'] ?? 'UNKNOWN';
        String entityType = data['entityType'] ?? 'unknown';

        actionCounts[action] = (actionCounts[action] ?? 0) + 1;
        entityTypeCounts[entityType] = (entityTypeCounts[entityType] ?? 0) + 1;
      }

      return {
        'totalActivities': snapshot.docs.length,
        'actionCounts': actionCounts,
        'entityTypeCounts': entityTypeCounts,
        'startDate': startDate,
        'endDate': endDate,
      };
    } catch (e) {
      print("❌ Error getting user activity summary: $e");
      return {};
    }
  }

  /// ✅ Delete old audit logs (for maintenance)
  Future<void> deleteOldAuditLogs({
    required String storeId,
    required DateTime olderThan,
  }) async {
    try {
      QuerySnapshot snapshot = await _db
          .collection('audit_trail')
          .where('storeId', isEqualTo: storeId)
          .where('timestamp', isLessThan: Timestamp.fromDate(olderThan))
          .get();

      WriteBatch batch = _db.batch();
      int count = 0;

      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
        count++;

        // Firestore batch limit is 500 operations
        if (count >= 500) {
          await batch.commit();
          batch = _db.batch();
          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      print("✅ Deleted ${snapshot.docs.length} old audit logs");
    } catch (e) {
      print("❌ Error deleting old audit logs: $e");
    }
  }

  /// ✅ Helper method to fetch user name from Firestore users collection
  Future<String> _getUserName(String userId) async {
    try {
      // Try to fetch from users collection
      final userDoc = await _db.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        return userData?['name'] ?? 'Unknown User';
      }

      // If not found in users, might be a customer
      final customerDoc = await _db.collection('customers').doc(userId).get();
      if (customerDoc.exists) {
        final customerData = customerDoc.data();
        return customerData?['name'] ?? 'Unknown User';
      }

      return 'Unknown User';
    } catch (e) {
      print("⚠️ Error fetching user name for $userId: $e");
      return 'Unknown User';
    }
  }
}
