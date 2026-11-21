import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static final _nimRegex = RegExp(r'^\d{5,20}$');
  static final _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static bool isValidEmail(String s) => _emailRegex.hasMatch(s.trim());
  static bool isValidNim(String s) => _nimRegex.hasMatch(s.trim());

  User? get currentUser => _auth.currentUser;

  /// Menerima email atau NIM/NIP, mengembalikan email untuk Firebase Auth.
  Future<String> _resolveEmail(String identifier) async {
    final id = identifier.trim();

    if (id.contains('@')) {
      if (!isValidEmail(id)) throw Exception('Format email tidak valid.');
      return id.toLowerCase();
    }

    if (!isValidNim(id)) {
      throw Exception('Masukkan NIM/NIP (angka) atau email.');
    }

    final doc = await _firestore.collection('nimIndex').doc(id).get();
    final email = doc.data()?['email'] as String?;
    if (email == null) {
      throw Exception('NIM/NIP atau kata sandi salah.');
    }
    return email;
  }

  // REGISTRASI
  Future<UserCredential> register({
    required String nama,
    required String nimNip,
    required String jenisAkun,
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanNim = nimNip.trim();

    if (!isValidEmail(cleanEmail)) {
      throw Exception('Format email tidak valid.');
    }
    if (jenisAkun != 'mahasiswa' && jenisAkun != 'pegawai') {
      throw Exception('Jenis akun tidak valid.');
    }
    if (jenisAkun == 'mahasiswa' && cleanNim.isEmpty) {
      throw Exception('NIM wajib diisi.');
    }
    if (cleanNim.isNotEmpty && !isValidNim(cleanNim)) {
      throw Exception('NIM/NIP harus berupa angka.');
    }

    final credential = await _auth.createUserWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );
    final user = credential.user!;

    try {
      // Semua dokumen ditulis sekaligus: berhasil semua atau gagal semua.
      final batch = _firestore.batch();

      batch.set(_firestore.collection('users').doc(user.uid), {
        'uid': user.uid,
        'nama': nama.trim(),
        'nimNip': cleanNim,
        'jenisAkun': jenisAkun,
        'email': cleanEmail,
        'role': 'pelapor',
        'fotoUrl': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // nimIndex: menjaga NIM/NIP unik sekaligus dipakai untuk login dengan NIM/NIP.
      if (cleanNim.isNotEmpty) {
        batch.set(_firestore.collection('nimIndex').doc(cleanNim), {
          'uid': user.uid,
          'email': cleanEmail,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();
    } on FirebaseException catch (e) {
      await user.delete();
      // Dokumen nimIndex yang sudah ada berarti NIM/NIP dipakai orang lain,
      // dan rules menolaknya sebagai permission-denied.
      if (e.code == 'permission-denied' && cleanNim.isNotEmpty) {
        throw Exception('NIM/NIP sudah terdaftar.');
      }
      rethrow;
    } catch (_) {
      await user.delete();
      rethrow;
    }

    // Gagal kirim email verifikasi tidak membatalkan pendaftaran;
    // user bisa memakai resendVerificationEmail().
    try {
      await user.sendEmailVerification();
    } catch (_) {}

    return credential;
  }

  // LOGIN SEMUA ROLE (identifier = NIM/NIP atau email)
  Future<UserCredential> login({
    required String identifier,
    required String password,
  }) async {
    final cleanEmail = await _resolveEmail(identifier);

    final credential = await _auth.signInWithEmailAndPassword(
      email: cleanEmail,
      password: password,
    );

    if (!credential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception(
        'Email belum diverifikasi. Silakan cek kotak masuk email kamu.',
      );
    }

    // Pastikan akun memiliki data profil FasPro
    final profile = await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .get();

    if (!profile.exists) {
      await _auth.signOut();
      throw Exception('Akun belum terdaftar di FasPro.');
    }

    return credential;
  }

  // KIRIM ULANG EMAIL VERIFIKASI
  Future<void> resendVerificationEmail() async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Pengguna belum login.');
    }

    await user.sendEmailVerification();
  }

  // LUPA PASSWORD (identifier = NIM/NIP atau email)
  Future<void> resetPassword(String identifier) async {
    final cleanEmail = await _resolveEmail(identifier);
    await _auth.sendPasswordResetEmail(email: cleanEmail);
  }

  // LOGOUT
  Future<void> logout() async {
    await _auth.signOut();
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {}
  }

  // LOGIN DENGAN GOOGLE (hanya untuk akun yang sudah terdaftar di FasPro)
  Future<UserCredential> signInWithGoogle() async {
    await GoogleSignIn.instance.initialize();

    final GoogleSignInAccount googleUser =
        await GoogleSignIn.instance.authenticate();

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;

    if (idToken == null) {
      throw Exception('Gagal mendapatkan token Google.');
    }

    final credential = GoogleAuthProvider.credential(idToken: idToken);

    final userCredential = await _auth.signInWithCredential(credential);

    // Memastikan akun sudah memiliki profil FasPro
    final uid = userCredential.user!.uid;
    final profile = await _firestore.collection('users').doc(uid).get();

    if (!profile.exists) {
      // Jika akun baru tercipta tanpa profil, hapus akun tersebut.
      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await userCredential.user!.delete();
      }

      await _auth.signOut();
      await GoogleSignIn.instance.signOut();

      throw Exception(
        'Akun belum terdaftar di FasPro. Silakan daftar terlebih dahulu.',
      );
    }

    if (!userCredential.user!.emailVerified) {
      await _auth.signOut();
      throw Exception('Email Google belum diverifikasi.');
    }

    return userCredential;
  }
}