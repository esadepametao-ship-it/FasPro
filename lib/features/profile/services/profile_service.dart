
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../shared/models/app_user.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mengambil data profil pengguna
  Future<AppUser?> getProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return AppUser.fromMap(doc.data()!);
  }

  // Mengubah profil pengguna
  Future<void> updateProfile({
    required String uid,
    required String nama,
    String? fotoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).update({
      'nama': nama.trim(),
      if (fotoUrl != null) 'fotoUrl': fotoUrl,
    });
  }

  // Mendengarkan perubahan profil secara langsung
  Stream<AppUser?> watchProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return AppUser.fromMap(doc.data()!);
    });
  }
}
