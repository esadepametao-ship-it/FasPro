
import 'package:cloud_firestore/cloud_firestore.dart';

class AppUser {
  final String uid;
  final String nama;
  final String nimNip;
  final String jenisAkun;
  final String email;
  final String role;
  final String? fotoUrl;
  final DateTime? createdAt;

  AppUser({
    required this.uid,
    required this.nama,
    required this.nimNip,
    required this.jenisAkun,
    required this.email,
    this.role = 'pelapor',
    this.fotoUrl,
    this.createdAt,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      nama: map['nama'] ?? '',
      nimNip: map['nimNip'] ?? '',
      jenisAkun: map['jenisAkun'] ?? 'mahasiswa',
      email: map['email'] ?? '',
      role: map['role'] ?? 'pelapor',
      fotoUrl: map['fotoUrl'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'nama': nama,
      'nimNip': nimNip,
      'jenisAkun': jenisAkun,
      'email': email,
      'role': role,
      'fotoUrl': fotoUrl,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
    };
  }

  AppUser copyWith({
    String? nama,
    String? nimNip,
    String? jenisAkun,
    String? email,
    String? role,
    String? fotoUrl,
  }) {
    return AppUser(
      uid: uid,
      nama: nama ?? this.nama,
      nimNip: nimNip ?? this.nimNip,
      jenisAkun: jenisAkun ?? this.jenisAkun,
      email: email ?? this.email,
      role: role ?? this.role,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      createdAt: createdAt,
    );
  }
}
