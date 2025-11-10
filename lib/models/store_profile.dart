class StoreProfile {
  final String storeId;
  final String name;
  final String ownerId;
  final String storeCode;
  final String contact;
  final String address; // ✅ Added
  final String houseNumber;
  final String street;
  final String barangay;

  StoreProfile({
    required this.storeId,
    required this.name,
    required this.ownerId,
    required this.storeCode,
    required this.contact,
    required this.address, // ✅ Added
    required this.houseNumber,
    required this.street,
    required this.barangay,
  });

  /// ✅ **copyWith Method for Updating StoreProfile**
  StoreProfile copyWith({
    String? storeId,
    String? name,
    String? ownerId,
    String? storeCode,
    String? contact,
    String? address, // ✅ Added
    String? houseNumber,
    String? street,
    String? barangay,
  }) {
    return StoreProfile(
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      storeCode: storeCode ?? this.storeCode,
      contact: contact ?? this.contact,
      address: address ?? this.address, // ✅ Added
      houseNumber: houseNumber ?? this.houseNumber,
      street: street ?? this.street,
      barangay: barangay ?? this.barangay,
    );
  }

  /// ✅ **Convert Firestore Document to StoreProfile**
  factory StoreProfile.fromMap(Map<String, dynamic> map) {
    return StoreProfile(
      storeId: map['storeId'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      storeCode: map['storeCode'] ?? '',
      contact: map['contact'] ?? '',
      address: map['address'] ?? '', // ✅ Added
      houseNumber: map['houseNumber'] ?? '',
      street: map['street'] ?? '',
      barangay: map['barangay'] ?? '',
    );
  }

  /// ✅ **Convert StoreProfile to Firestore-Compatible Map**
  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'name': name,
      'ownerId': ownerId,
      'storeCode': storeCode,
      'contact': contact,
      'address': address, // ✅ Added
      'houseNumber': houseNumber,
      'street': street,
      'barangay': barangay,
    };
  }
}
