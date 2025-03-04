class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String phone;
  final String document;
  final String status;
  final String role;
  final String storeId;
  final bool debts;
  final bool reports;
  final bool pos;
  final bool ims;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    required this.phone,
    required this.storeId,
    required this.document,
    required this.status,
    required this.role,
    required this.debts,
    required this.reports,
    required this.pos,
    required this.ims,
  });

  /// ✅ **copyWith Method for Updating UserProfile**
  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    String? phone,
    String? document,
    String? status,
    String? role,
    String? storeId,
    bool? debts,
    bool? reports,
    bool? pos,
    bool? ims,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      storeId: storeId ?? this.storeId,
      document: document ?? this.document,
      status: status ?? this.status,
      role: role ?? this.role,
      debts: debts ?? this.debts,
      reports: reports ?? this.reports,
      pos: pos ?? this.pos,
      ims: ims ?? this.ims,
    );
  }

  /// ✅ **Convert Firestore Document to UserProfile**
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    print("Raw User Map: $map"); // Debugging line

    return UserProfile(
      uid: map['uid'] ?? '', // Check if UID is also missing
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      storeId: map['storeId'] ?? '', // ✅ Ensure this is mapped
      document: map['document'] ?? '',
      status: map['status'] ?? '',
      role: map['role'] ?? '',
      debts: map['debts'] ?? false,
      reports: map['reports'] ?? false,
      pos: map['pos'] ?? false,
      ims: map['ims'] ?? false,
    );
  }

  /// ✅ **Convert UserProfile to Firestore-Compatible Map**
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone,
      'storeId': storeId,
      'document': document,
      'status': status,
      'role': role,
      'debts': debts,
      'reports': reports,
      'pos': pos,
      'ims': ims,
    };
  }
}
