import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String email;
  final String nik; // Nomor Induk Kependudukan
  final String? ktpImageUrl;
  final bool isVerified;
  final bool isAdmin; // Village Head
  final String? villageName;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.nik,
    this.ktpImageUrl,
    this.isVerified = false,
    this.isAdmin = false,
    this.villageName,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      nik: data['nik']?.toString() ?? '',
      ktpImageUrl: data['ktpImageUrl']?.toString(),
      isVerified: data['isVerified'] ?? false,
      isAdmin: data['isAdmin'] ?? false,
      villageName: data['villageName']?.toString(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'nik': nik,
      'ktpImageUrl': ktpImageUrl,
      'isVerified': isVerified,
      'isAdmin': isAdmin,
      'villageName': villageName,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? nik,
    String? ktpImageUrl,
    bool? isVerified,
    bool? isAdmin,
    String? villageName,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      nik: nik ?? this.nik,
      ktpImageUrl: ktpImageUrl ?? this.ktpImageUrl,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      villageName: villageName ?? this.villageName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
