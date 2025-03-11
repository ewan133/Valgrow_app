import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/customer_model.dart';

class DebtsDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

 /// ✅ Fetch all customers by storeId (not just debt-related)
Future<List<CustomerDetails>> fetchAllCustomersByStoreId(String storeId) async {
  try {
    QuerySnapshot querySnapshot = await _db
        .collection('customers')
        .where('storeId', isEqualTo: storeId) // ✅ Get all customers for this store
        .get();

    List<CustomerDetails> customers = querySnapshot.docs.map((doc) {
      return CustomerDetails.fromDocument(doc);
    }).toList();

    for (var customer in customers) {
      print("✅ Customer ID: ${customer.customerId}");
      print("Name: ${customer.name}");
      print("Phone: ${customer.phone}");
      print("Total Debt: ₱${customer.totalDebt}");
      print("Store ID: ${customer.storeId}");
      print("------");
    }

    return customers; // ✅ Return the list of customers
  } catch (e) {
    print("❌ Error retrieving customers for storeId $storeId: $e");
    return []; // ✅ Always return an empty list on error instead of null
  }
}


  /// ✅ Add a new customer to Firestore
  Future<CustomerDetails?> addNewCustomer({
    required String storeId,
    required String name,
    required String phone,
    String? imageUrl,
  }) async {
    try {
      // ✅ Check if a customer with the same phone number already exists
      QuerySnapshot existingCustomerSnapshot = await _db
          .collection('customers')
          .where('storeId', isEqualTo: storeId)
          .where('phone', isEqualTo: phone)
          .get();

      if (existingCustomerSnapshot.docs.isNotEmpty) {
        print("⚠️ Customer with phone $phone already exists.");
        return null; // Return null if customer already exists
      }

      // ✅ Create a new customer document
      DocumentReference newCustomerRef = _db.collection('customers').doc();

      CustomerDetails newCustomer = CustomerDetails(
        customerId: newCustomerRef.id,
        storeId: storeId,
        name: name,
        phone: phone,
        totalDebt: 0.0, // New customers start with zero debt
        imageUrl: imageUrl,
        lastTransactionDate: null, // No transaction yet
      );

      // ✅ Save the new customer to Firestore
      await newCustomerRef.set(newCustomer.toMap());

      print(
          "✅ New customer added: ${newCustomer.name} (ID: ${newCustomer.customerId})");
      return newCustomer;
    } catch (e) {
      print("❌ Error adding new customer: $e");
      throw e;
    }
  }

  fetchCustomersByStoreId(String storeId) {}
}
