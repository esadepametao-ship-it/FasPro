
import 'package:flutter/material.dart';

import 'package:faspro/shared/models/app_user.dart';
import 'package:faspro/features/profile/services/profile_service.dart';

class EditProfilePage extends StatefulWidget {
  final AppUser user;

  const EditProfilePage({
    super.key,
    required this.user,
  });

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _fotoUrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nama = TextEditingController(text: widget.user.nama);
    _fotoUrl = TextEditingController(
      text: widget.user.fotoUrl ?? '',
    );
  }

  @override
  void dispose() {
    _nama.dispose();
    _fotoUrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await ProfileService().updateProfile(
        uid: widget.user.uid,
        nama: _nama.text,
        fotoUrl: _fotoUrl.text.trim().isEmpty
            ? null
            : _fotoUrl.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil berhasil diperbarui.'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nama,
                decoration: const InputDecoration(
                  labelText: 'Nama lengkap',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty
                        ? 'Nama tidak boleh kosong'
                        : null,
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: widget.user.nimNip,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'NIM / NIP',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                initialValue: widget.user.email,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Email universitas',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _fotoUrl,
                decoration: const InputDecoration(
                  labelText: 'URL Foto Profil',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: _loading ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}