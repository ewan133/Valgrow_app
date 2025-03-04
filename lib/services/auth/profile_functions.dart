import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class ProfileFunctions {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates a profile for the user and a store if they are an owner
  Future<void> createStoreOwnerProfile(
      String userEmail, String name, String phone) async {
    try {
      await _firestore.collection('users').doc(userEmail).set({
        'name': name,
        'phone': phone,
        'role': 'store_owner',
      });

      print('User profile created: $name ($userEmail)');

      // Create a store for the owner
      String storeId = _firestore.collection('stores').doc().id;
      String storeCode = _generateStoreCode();

      await _firestore.collection('stores').doc(storeId).set({
        'name': '$name\'s Store', // Default store name
        'ownerId': userEmail,
        'storeCode': storeCode,
      });

      print(
          'Store created successfully: ${name}\'s Store with code $storeCode');
    } catch (e) {
      print('Error creating profile and store: $e');
    }
  }

  /// Creates a profile for an employee and affiliates them with a store
  Future<void> createEmployeeProfile(
      String userEmail, String name, String phone, String storeCode) async {
    try {
      await _firestore.collection('users').doc(userEmail).set({
        'name': name,
        'phone': phone,
        'role': 'employee',
      });

      print('User profile created: $name ($userEmail)');

      QuerySnapshot storeQuery = await _firestore
          .collection('stores')
          .where('storeCode', isEqualTo: storeCode)
          .limit(1)
          .get();

      if (storeQuery.docs.isEmpty) {
        print('Invalid store code');
        return;
      }

      String storeId = storeQuery.docs.first.id;
      String affiliationId =
          _firestore.collection('storeAffiliations').doc().id;

      await _firestore.collection('storeAffiliations').doc(affiliationId).set({
        'employeeId': userEmail,
        'storeId': storeId,
      });

      print('Employee affiliated successfully to store ID: $storeId');
    } catch (e) {
      print('Error creating profile and affiliating employee: $e');
    }
  }

  /// Generates a random 6-digit store code
  String _generateStoreCode() {
    final Random random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  /// Fetches all details of the current user
  Future<Map<String, dynamic>?> getCurrentUserInfo(String userEmail) async {
    try {
      // Fetch user profile
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userEmail).get();

      if (!userDoc.exists) {
        print('User not found');
        return null;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      String role = userData['role'];

      if (role == 'store_owner') {
        // Fetch store details for owner
        QuerySnapshot storeQuery = await _firestore
            .collection('stores')
            .where('ownerId', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (storeQuery.docs.isNotEmpty) {
          userData['store'] = storeQuery.docs.first.data();
        }
      } else if (role == 'employee') {
        // Fetch store affiliation for employee
        QuerySnapshot affiliationQuery = await _firestore
            .collection('storeAffiliations')
            .where('employeeId', isEqualTo: userEmail)
            .limit(1)
            .get();

        if (affiliationQuery.docs.isNotEmpty) {
          String storeId = affiliationQuery.docs.first['storeId'];

          DocumentSnapshot storeDoc =
              await _firestore.collection('stores').doc(storeId).get();

          if (storeDoc.exists) {
            userData['affiliatedStore'] = storeDoc.data();
          }
        }
      }

      return userData;
    } catch (e) {
      print('Error fetching user details: $e');
      return null;
    }
  }

  
}
