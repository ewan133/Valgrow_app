import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/services/database/audit_database.dart';

class PromotionDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuditDatabase _auditDb = AuditDatabase();

  /// ✅ Add a new promotion with receipt, store images, and date range
  Future<void> addPromotion({
    required String receiptImageUrl,
    required String storeImageUrl, // ✅ Store image
    required String title,
    required String description,
    required double amount,
    required String storeId,
    String? userId, // ✅ Added userId parameter
    required DateTime? startDate, // ✅ New start date
    required DateTime? endDate,
    required String paymentMethod, // ✅ New payment method
    String status = "pending", // default status
  }) async {
    try {
      final promotionData = {
        "receipt_image": receiptImageUrl,
        "store_image": storeImageUrl,
        "title": title,
        "description": description,
        "amount": amount,
        "storeId": storeId,
        "status": status,
        "payment_method": paymentMethod, // ✅ Store payment method
        "start_date": Timestamp.fromDate(startDate!),
        "end_date": Timestamp.fromDate(endDate!),
        "created_at": FieldValue.serverTimestamp(),
      };

      final docRef = await _db.collection('promotions').add(promotionData);

      // ✅ Log audit trail
      await _auditDb.logAudit(
        storeId: storeId,
        userId: userId ?? storeId, // ✅ Use actual userId if provided
        action: 'CREATE_PROMOTION',
        entityType: 'promotion',
        entityId: docRef.id,
        description:
            'Promotion created: $title - ₱${amount.toStringAsFixed(2)} ($paymentMethod)',
        metadata: {
          'title': title,
          'amount': amount,
          'paymentMethod': paymentMethod,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'status': status,
        },
      );

      print("✅ Promotion added successfully with date range");
    } catch (e) {
      print("❌ Failed to add promotion: $e");
      rethrow;
    }
  }

  /// ✅ Fetch all promotions for a given store
  Future<List<Map<String, dynamic>>> fetchStorePromotions(
      String storeId) async {
    try {
      final querySnapshot = await _db
          .collection('promotions')
          .where('storeId', isEqualTo: storeId)
          .orderBy('created_at', descending: true)
          .get();

      print("🔎 Promotions for store $storeId:");
      for (var doc in querySnapshot.docs) {
        final promo = doc.data();
        print("📌 Promotion ID: ${doc.id}");
        print("   Title: ${promo['title']}");
        print("   Description: ${promo['description']}");
        print("   Status: ${promo['status']}");
        print("   Amount: ${promo['amount']}");
        print("   Start: ${(promo['start_date'] as Timestamp).toDate()}");
        print("   End: ${(promo['end_date'] as Timestamp).toDate()}");
        print("   Store Image: ${promo['store_image']}");
        print("   Receipt Image: ${promo['receipt_image']}");
        print("---------------");
      }

      return querySnapshot.docs
          .map((doc) => {
                "id": doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print("❌ Failed to fetch store promotions: $e");
      rethrow;
    }
  }

  /// ✅ Update promotion status
  Future<void> updatePromotionStatus(String promotionId, String status,
      {String? userId}) async {
    try {
      final promotionRef = _db.collection('promotions').doc(promotionId);
      final promotionDoc = await promotionRef.get();
      final promotionData = promotionDoc.data();

      await promotionRef.update({
        'status': status,
        'updated_at': FieldValue.serverTimestamp(),
      });

      // ✅ Log audit trail
      if (promotionData != null) {
        await _auditDb.logAudit(
          storeId: promotionData['storeId'] ?? '',
          userId: userId ??
              promotionData['storeId'] ??
              '', // ✅ Use actual userId if provided
          action: 'UPDATE_PROMOTION_STATUS',
          entityType: 'promotion',
          entityId: promotionId,
          description: 'Promotion status changed to: $status',
          metadata: {
            'oldStatus': promotionData['status'],
            'newStatus': status,
            'title': promotionData['title'],
            'amount': promotionData['amount'],
          },
        );
      }

      print("✅ Promotion status updated successfully");
    } catch (e) {
      print("❌ Failed to update promotion status: $e");
      rethrow;
    }
  }

  /// ✅ Delete a promotion
  Future<void> deletePromotion(String promotionId, {String? userId}) async {
    try {
      final promotionRef = _db.collection('promotions').doc(promotionId);
      final promotionDoc = await promotionRef.get();
      final promotionData = promotionDoc.data();

      await promotionRef.delete();

      // ✅ Log audit trail
      if (promotionData != null) {
        await _auditDb.logAudit(
          storeId: promotionData['storeId'] ?? '',
          userId: userId ??
              promotionData['storeId'] ??
              '', // ✅ Use actual userId if provided
          action: 'DELETE_PROMOTION',
          entityType: 'promotion',
          entityId: promotionId,
          description:
              'Promotion deleted: ${promotionData['title']} - ₱${promotionData['amount']}',
          metadata: {
            'title': promotionData['title'],
            'amount': promotionData['amount'],
            'status': promotionData['status'],
            'paymentMethod': promotionData['payment_method'],
          },
        );
      }

      print("✅ Promotion deleted successfully");
    } catch (e) {
      print("❌ Failed to delete promotion: $e");
      rethrow;
    }
  }

  /// ✅ Update promotion details
  Future<void> updatePromotion({
    required String promotionId,
    String? userId, // ✅ Added userId parameter
    String? title,
    String? description,
    double? amount,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? receiptImageUrl,
    String? storeImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': FieldValue.serverTimestamp(),
      };

      if (title != null) updateData['title'] = title;
      if (description != null) updateData['description'] = description;
      if (amount != null) updateData['amount'] = amount;
      if (startDate != null)
        updateData['start_date'] = Timestamp.fromDate(startDate);
      if (endDate != null) updateData['end_date'] = Timestamp.fromDate(endDate);
      if (status != null) updateData['status'] = status;
      if (receiptImageUrl != null)
        updateData['receipt_image'] = receiptImageUrl;
      if (storeImageUrl != null) updateData['store_image'] = storeImageUrl;

      final promotionRef = _db.collection('promotions').doc(promotionId);
      final promotionDoc = await promotionRef.get();
      final oldData = promotionDoc.data();

      await promotionRef.update(updateData);

      // ✅ Log audit trail
      if (oldData != null) {
        await _auditDb.logAudit(
          storeId: oldData['storeId'] ?? '',
          userId: userId ??
              oldData['storeId'] ??
              '', // ✅ Use actual userId if provided
          action: 'UPDATE_PROMOTION',
          entityType: 'promotion',
          entityId: promotionId,
          description: 'Promotion updated: ${title ?? oldData['title']}',
          metadata: {
            'updatedFields': updateData.keys.toList(),
            'title': title ?? oldData['title'],
            'newAmount': amount,
            'oldAmount': oldData['amount'],
          },
        );
      }

      print("✅ Promotion updated successfully");
    } catch (e) {
      print("❌ Failed to update promotion: $e");
      rethrow;
    }
  }

  /// ✅ Get promotion by ID
  Future<Map<String, dynamic>?> getPromotionById(String promotionId) async {
    try {
      final docSnapshot =
          await _db.collection('promotions').doc(promotionId).get();

      if (docSnapshot.exists) {
        return {
          "id": docSnapshot.id,
          ...docSnapshot.data()!,
        };
      }
      return null;
    } catch (e) {
      print("❌ Failed to get promotion: $e");
      rethrow;
    }
  }

  /// ✅ Fetch promotions by status
  Future<List<Map<String, dynamic>>> fetchPromotionsByStatus(
      String storeId, String status) async {
    try {
      final querySnapshot = await _db
          .collection('promotions')
          .where('storeId', isEqualTo: storeId)
          .where('status', isEqualTo: status)
          .orderBy('created_at', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => {
                "id": doc.id,
                ...doc.data(),
              })
          .toList();
    } catch (e) {
      print("❌ Failed to fetch promotions by status: $e");
      rethrow;
    }
  }

  /// ✅ Stream promotions for real-time updates
  Stream<List<Map<String, dynamic>>> streamStorePromotions(String storeId) {
    return _db
        .collection('promotions')
        .where('storeId', isEqualTo: storeId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => {
                "id": doc.id,
                ...doc.data(),
              })
          .toList();
    });
  }

  /// ✅ Check if promotion is currently active based on dates
  bool isPromotionActiveByDate(Map<String, dynamic> promotion) {
    try {
      final now = DateTime.now();
      final startDate = (promotion['start_date'] as Timestamp).toDate();
      final endDate = (promotion['end_date'] as Timestamp).toDate();

      return now.isAfter(startDate) && now.isBefore(endDate);
    } catch (e) {
      print("❌ Failed to check promotion date validity: $e");
      return false;
    }
  }

  /// ✅ Bulk update promotion status
  Future<void> bulkUpdatePromotionStatus(
      List<String> promotionIds, String status,
      {String? userId}) async {
    try {
      final batch = _db.batch();

      for (String id in promotionIds) {
        final docRef = _db.collection('promotions').doc(id);
        batch.update(docRef, {
          'status': status,
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // ✅ Log audit trail for bulk update
      for (String id in promotionIds) {
        final promotionDoc = await _db.collection('promotions').doc(id).get();
        final promotionData = promotionDoc.data();

        if (promotionData != null) {
          await _auditDb.logAudit(
            storeId: promotionData['storeId'] ?? '',
            userId: userId ??
                promotionData['storeId'] ??
                '', // ✅ Use actual userId if provided
            action: 'BULK_UPDATE_PROMOTION_STATUS',
            entityType: 'promotion',
            entityId: id,
            description: 'Bulk status update to: $status',
            metadata: {
              'oldStatus': promotionData['status'],
              'newStatus': status,
              'title': promotionData['title'],
              'bulkOperationCount': promotionIds.length,
            },
          );
        }
      }

      print("✅ Bulk status update completed successfully");
    } catch (e) {
      print("❌ Failed to bulk update promotion status: $e");
      rethrow;
    }
  }

  /// ✅ Fetch promotion configuration (price per day, min days, payment methods) from barangayProfiles
  Future<Map<String, dynamic>> fetchPromotionConfig(String barangayName) async {
    try {
      final barangayLower = barangayName.toLowerCase().trim();
      print("🔍 Fetching config for barangay: $barangayLower");

      // Query barangayProfiles collection using the barangay field
      final querySnapshot = await _db
          .collection('barangayProfiles')
          .where('barangayName', isEqualTo: barangayLower)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        print("⚠️ Barangay profile not found for: $barangayLower");
        return {
          "price_per_day": 15.0,
          "min_days": 7,
          "payment_methods": [],
        };
      }

      final barangayData = querySnapshot.docs.first.data();

      // Extract promotionRules map
      final promotionRules =
          barangayData["promotionRules"] as Map<String, dynamic>? ?? {};

      // Extract paymentMethods array
      final paymentMethodsArray =
          barangayData["paymentMethods"] as List<dynamic>? ?? [];

      final config = {
        "price_per_day": promotionRules["price_per_day"]?.toDouble() ?? 15.0,
        "min_days": promotionRules["min_days"] ?? 7,
        "payment_methods": paymentMethodsArray,
      };

      // ✅ Debug print the config result
      print("🔎 Promotion Config Fetched from barangayProfiles:");
      print("   Barangay: $barangayLower");
      print("   Price per day: ${config["price_per_day"]}");
      print("   Min days: ${config["min_days"]}");
      print("   Payment methods count: ${paymentMethodsArray.length}");
      for (var i = 0; i < paymentMethodsArray.length; i++) {
        final method = paymentMethodsArray[i];
        print("     ▶ Method #${i + 1}: ${method["type"]}");
        print("        Account: ${method["accountNumber"]}");
        print("        QR Code: ${method["qrCode"] ?? 'N/A'}");
      }

      return config;
    } catch (e) {
      print("❌ Failed to fetch promotion config from barangayProfiles: $e");
      return {
        "price_per_day": 15.0,
        "min_days": 7,
        "payment_methods": [],
      };
    }
  }
}
