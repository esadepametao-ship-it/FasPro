import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:faspro/core/theme/app_colors.dart';
import 'package:faspro/features/auth/screens/login_page.dart';
import 'package:faspro/features/auth/services/auth_service.dart';
import 'package:faspro/features/reports/screens/home_page.dart';
import 'package:faspro/features/admin/screens/home_page.dart';
import 'package:faspro/features/technician/screens/home_page.dart';

/// Pintu masuk aplikasi. Pasang sebagai `home:` di MaterialApp.
///
/// Alur:
///   belum login / email belum terverifikasi -> LoginPage
///   sudah login -> baca role di users/{uid} -> halaman utama sesuai role
///
/// Tidak perlu Navigator.push setelah login/logout: halaman berganti otomatis.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, authSnap) {
        if (authSnap.connectionState == ConnectionState.waiting) {
          return const _Loading();
        }

        final user = authSnap.data;

        // Akun yang baru register (email belum diverifikasi) tetap di halaman login.
        if (user == null || !user.emailVerified) return const LoginPage();

        return _RoleRouter(uid: user.uid);
      },
    );
  }
}

class _RoleRouter extends StatelessWidget {
  final String uid;
  const _RoleRouter({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snap) {
        if (snap.hasError) {
          return const _Loading(
            message: 'Gagal memuat data akun.',
            showLogout: true,
          );
        }
        if (!snap.hasData) return const _Loading();

        final data = snap.data!.data();
        // Dokumen profil belum ada (mis. sedang dibuat). Beri jalan keluar kalau macet.
        if (data == null) return const _Loading(showLogout: true);

        // TODO (Anggota 1): setelah Custom Claims aktif, baca role dari
        // user.getIdTokenResult().claims?['role'] sebagai sumber utama.
        final role = ((data['role'] as String?) ?? 'pelapor').toLowerCase();

        switch (role) {
          case 'admin':
            return const AdminHomePage();
          case 'teknisi':
            return const TechnicianHomePage();
          default:
            return const ReporterHomePage();
        }
      },
    );
  }
}

class _Loading extends StatelessWidget {
  final String? message;
  final bool showLogout;
  const _Loading({this.message, this.showLogout = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(message!),
            ],
            if (showLogout) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => AuthService().logout(),
                child: const Text('Keluar'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}