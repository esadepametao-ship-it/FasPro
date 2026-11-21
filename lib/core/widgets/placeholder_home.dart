import 'package:flutter/material.dart';
import 'package:faspro/core/theme/app_colors.dart';
import 'package:faspro/features/auth/services/auth_service.dart';
import 'package:faspro/features/profile/screens/profile_page.dart';

/// Halaman sementara untuk tiap role. Anggota lain mengganti isi halaman
/// utamanya masing-masing, jadi widget ini boleh dihapus kalau sudah tidak dipakai.
class PlaceholderHome extends StatelessWidget {
  final String title;
  final String subtitle;

  const PlaceholderHome({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            tooltip: 'Profil',
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => AuthService().logout(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.construction, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(subtitle, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}