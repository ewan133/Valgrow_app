import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:valgrow_ui/models/store_profile.dart';
import 'package:valgrow_ui/models/user_profile.dart';

class DatabaseService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /*
      Methosds for profile creation
      - owner profile creation
      - employee profile creation
      - generate random store code
    */

  //create profile for owners
  Future<void> createStoreOwnerProfile(
      String userEmail, String name, String phone) async {
    try {
      String userId = _auth.currentUser!.uid; // Get authenticated user ID

      // Generate store ID and store code
      String storeId = _db.collection('stores').doc().id;
      String storeCode = _generateStoreCode();

      await _db.runTransaction((transaction) async {
        // Create user profile for store owner
        DocumentReference userRef = _db.collection('users').doc(userId);
        transaction.set(userRef, {
          'name': name,
          'phone': phone,
          'email': userEmail,
          'role': 'Store Owner',
          'storeId': storeId, // Assign storeId
          'pos': true,
          'ims': true,
          'reports': true,
          'debts': true,
          'expenses': true,
          'status': 'Unverified',
          'document': '',
          'token': '',
        });

        print('User profile created: $name ($userEmail)');

        // Create the store associated with the owner
        DocumentReference storeRef = _db.collection('stores').doc(storeId);
        transaction.set(storeRef, {
          'name': "$name's Store", // Default store name
          'ownerId': userId, // Assign Firebase UID
          'storeCode': storeCode,
          'contact': phone,
        });

        print(
            'Store created successfully: ${name}\'s Store with code $storeCode');
      });
    } catch (e) {
      print('Error creating profile and store: $e');
    }
  }

  // create profile for employees
  Future<void> createEmployeeProfile(
      String userEmail, String name, String phone, String storeCode) async {
    try {
      if (_auth.currentUser == null) {
        print('Error: No authenticated user found.');
        return;
      }

      String userId = _auth.currentUser!.uid;

      await _db.runTransaction((transaction) async {
        // Find store by storeCode
        QuerySnapshot storeQuery = await _db
            .collection('stores')
            .where('storeCode', isEqualTo: storeCode)
            .limit(1)
            .get();

        if (storeQuery.docs.isEmpty) {
          throw Exception('Invalid store code: No matching store found.');
        }

        String storeId = storeQuery.docs.first.id;

        // Create user profile for employee
        DocumentReference userRef = _db.collection('users').doc(userId);
        transaction.set(userRef, {
          'name': name,
          'phone': phone,
          'email': userEmail,
          'role': 'Employee',
          'storeId': storeId, // Assign storeId
          'pos': true,
          'ims': false,
          'reports': false,
          'debts': true,
          'expenses': false,
          'token': '',
        });

        print('User profile created: $name ($userEmail)');

        // Create store affiliation
        DocumentReference affiliationRef =
            _db.collection('storeAffiliations').doc();
        transaction.set(affiliationRef, {
          'employeeId': userId, // Use Firebase UID instead of email
          'storeId': storeId,
          'pos': true,
          'ims': false,
          'reports': false,
          'debts': true,
          'expenses': false,
        });

        print('Employee affiliated successfully to store ID: $storeId');
      });
    } catch (e) {
      print('Error creating profile and affiliating employee: $e');
    }
  }

  /// Generates a random 6-digit store code
  String _generateStoreCode() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final Random random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)])
        .join();
  }

  /*
    Methods for getting the user profile
      Whats needed:
      - profile details
      - store affiliation details
      - permission details
    */

  // get user full details
  Future<UserProfile?> getCurrentUserInfo(String uid) async {
    try {
      print('Fetching user info for UID: $uid');

      DocumentSnapshot userDoc = await _db.collection('users').doc(uid).get();

      if (!userDoc.exists) {
        print('❌ User not found');
        return null;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      userData['uid'] = uid; // ✅ Manually add UID to the map

      print('✅ User document data: $userData');

      return UserProfile.fromMap(userData);
    } catch (e) {
      print('❌ Error fetching user details: $e');
      return null;
    }
  }

  // retrieve store code of the owner
  Future<StoreProfile?> getStoreInfo(String storeId) async {
    try {
      print('Fetching store info for Store ID: $storeId');

      DocumentSnapshot storeDoc =
          await _db.collection('stores').doc(storeId).get();

      if (!storeDoc.exists) {
        print('❌ No store found with this store ID.');
        return null;
      }

      Map<String, dynamic> storeData = storeDoc.data() as Map<String, dynamic>;
      storeData['storeId'] = storeId; // ✅ Manually add storeId to the map

      print('✅ Store document data: $storeData');

      return StoreProfile.fromMap(storeData);
    } catch (e) {
      print('❌ Error fetching store details: $e');
      return null;
    }
  }

  /*
      Methods for updating user data and store data
      - user phone number update
      - store name update
      
    */

  // update user phone number
  Future<void> updatePhoneNumber(String uid, String phoneNumber) async {
    try {
      await _db.collection('users').doc(uid).update({'phone': phoneNumber});
    } catch (e) {
      print(e);
    }
  }

  // update store name
  Future<void> updateStoreName(String storeId, String name) async {
    try {
      await _db.collection('stores').doc(storeId).update({'name': name});
    } catch (e) {
      print(e);
    }
  }

  // update user document
  Future<void> updateUserDocument(String uid, String document) async {
    try {
      await _db
          .collection('users')
          .doc(uid)
          .update({'document': document, 'status': 'Pending'});
      print("User profile updated successfully: $document");
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  // Generate and update store code
  Future<void> generateAndUpdateStoreCode(String storeId) async {
    try {
      String newStoreCode = _generateStoreCode(); // Generate a new store code

      // Update the store's storeCode in Firestore
      await _db
          .collection('stores')
          .doc(storeId)
          .update({'storeCode': newStoreCode});

      print("✅ Store Code updated successfully: $newStoreCode");
    } catch (e) {
      print("❌ Error updating store code: $e");
    }
  }

  // Get owner token
  Future<String?> getStoreOwnerFcmToken(String ownerId) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(ownerId).get();
    return userDoc.exists ? userDoc["token"] : null;
  }

  /// ✅ **Retrieve and store/update FCM token on login**
  Future<void> saveUserFcmToken(String userId) async {
    try {
      // ✅ Get the latest FCM token
      String? newFcmToken = await FirebaseMessaging.instance.getToken();

      if (newFcmToken == null) {
        print("❌ Failed to get FCM token.");
        return;
      }

      // ✅ Get the current stored token from Firestore
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        print("❌ User not found in Firestore.");
        return;
      }

      // ✅ Debug: Print Firestore Data
      print("Firestore User Data: ${userDoc.data()}");

      String? savedFcmToken = userDoc["token"]; // Use the correct field

      // ✅ Only update if the token has changed or is missing
      if (savedFcmToken == null || savedFcmToken != newFcmToken) {
        await _db
            .collection('users')
            .doc(userId)
            .update({"token": newFcmToken});
        print("✅ Updated FCM token: $newFcmToken");
      } else {
        print("✅ FCM token is up-to-date, no update needed.");
      }
    } catch (e) {
      print("❌ Error updating FCM token: $e");
    }
  }
}
