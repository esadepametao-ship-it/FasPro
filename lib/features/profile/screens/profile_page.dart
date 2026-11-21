
import 'package:flutter/material.dart';
import 'package:faspro/shared/models/app_user.dart';
import 'package:faspro/features/auth/services/auth_service.dart';
import 'package:faspro/features/profile/services/profile_service.dart';
import 'package:faspro/features/profile/screens/edit_profile_page.dart';
import 'package:faspro/features/auth/screens/login_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  String _roleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Admin Fasilitas';
      case 'teknisi':
        return 'Teknisi';
      default:
        return 'Pelapor';
    }
  }

  Future<void> _logout(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Keluar?'),
        content: const Text(
          'Kamu harus masuk lagi untuk memakai FasPro.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    await AuthService().logout();
    if (context.mounted) Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final uid = AuthService().currentUser?.uid;

    if (uid == null) {
      return const LoginPage();
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: StreamBuilder<AppUser?>(
        stream: ProfileService().watchProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Gagal memuat profil.'),
            );
          }

          final user = snapshot.data;

          if (user == null) {
            return const Center(
              child: Text('Data profil tidak ditemukan.'),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundImage: user.fotoUrl != null &&
                          user.fotoUrl!.isNotEmpty
                      ? NetworkImage(user.fotoUrl!)
                      : null,
                  child: user.fotoUrl == null ||
                          user.fotoUrl!.isEmpty
                      ? Text(
                          user.nama.isNotEmpty
                              ? user.nama[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 32),
                        )
                      : null,
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  user.nama,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),

              const SizedBox(height: 6),

              Center(
                child: Chip(
                  label: Text(_roleLabel(user.role)),
                ),
              ),

              const SizedBox(height: 16),

              Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.badge_outlined),
                      title: const Text('NIM / NIP'),
                      subtitle: Text(user.nimNip),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.school_outlined),
                      title: const Text('Jenis Akun'),
                      subtitle: Text(user.jenisAkun),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.email_outlined),
                      title: const Text('Email'),
                      subtitle: Text(user.email),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              FilledButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfilePage(user: user),
                    ),
                  );
                },
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Edit Profil'),
              ),

              const SizedBox(height: 10),

              OutlinedButton(
                onPressed: () => _logout(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Keluar'),
              ),
            ],
          );
        },
      ),
    );
  }
}