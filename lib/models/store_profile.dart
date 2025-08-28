class StoreProfile {
  final String storeId;
  final String name;
  final String ownerId;
  final String storeCode;
  final String contact;
  final String address; // ✅ Added

  StoreProfile({
    required this.storeId,
    required this.name,
    required this.ownerId,
    required this.storeCode,
    required this.contact,
    required this.address, // ✅ Added
  });

  /// ✅ **copyWith Method for Updating StoreProfile**
  StoreProfile copyWith({
    String? storeId,
    String? name,
    String? ownerId,
    String? storeCode,
    String? contact,
    String? address, // ✅ Added
  }) {
    return StoreProfile(
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      storeCode: storeCode ?? this.storeCode,
      contact: contact ?? this.contact,
      address: address ?? this.address, // ✅ Added
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
    };
  }
}
