import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:faspro/core/theme/app_colors.dart';
import 'package:faspro/features/auth/services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const _teal = AppColors.primary;
  static const _ink = AppColors.ink;
  static const _muted = AppColors.muted;
  static const _radius = 18.0;

  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _nimNip = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  final _auth = AuthService();

  String _jenisAkun = 'mahasiswa';
  bool _loading = false;
  bool _obscure = true;

  bool get _isMahasiswa => _jenisAkun == 'mahasiswa';

  @override
  void dispose() {
    _nama.dispose();
    _nimNip.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'Email sudah terdaftar. Silakan masuk.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'weak-password':
          return 'Kata sandi terlalu lemah.';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet.';
        default:
          return error.message ?? 'Terjadi kesalahan saat mendaftar.';
      }
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  Future<void> _showNotice(
    String title,
    String message, {
    bool success = false,
  }) async {
    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                success ? Icons.mark_email_read_outlined : Icons.error_outline,
                color: success ? Colors.green : Colors.red,
                size: 52,
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _auth.register(
        nama: _nama.text,
        nimNip: _nimNip.text,
        jenisAkun: _jenisAkun,
        email: _email.text,
        password: _password.text,
      );

      // Keluar agar pengguna harus verifikasi email dahulu.
      await _auth.logout();

      await _showNotice(
        'Registrasi berhasil!',
        'Kami mengirim tautan verifikasi ke ${_email.text.trim()}. '
            'Verifikasi dulu, lalu masuk dengan NIM/NIP atau email.',
        success: true,
      );

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      await _showNotice('Registrasi Gagal', _errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Dekorasi input yang sama dengan halaman login.
  InputDecoration _decoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(_radius),
          borderSide: BorderSide(color: c, width: w),
        );
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: _muted),
      prefixIcon: Icon(icon, color: _teal, size: 22),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 18),
      border: border(Colors.transparent),
      enabledBorder: border(Colors.transparent),
      focusedBorder: border(_teal, 1.5),
      errorBorder: border(Colors.red.shade700),
      focusedErrorBorder: border(Colors.red.shade700, 1.5),
    );
  }

  /// Pembungkus bayangan lembut untuk setiap kolom.
  Widget _card(Widget child) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_radius),
        boxShadow: [
          BoxShadow(
            color: _teal.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return _card(
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: _ink),
        decoration: _decoration(hint: hint, icon: icon, suffix: suffix),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius));

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1F0EB), Color(0xFFF6FAF8)],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tombol kembali
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Material(
                            color: Colors.white,
                            shape: const CircleBorder(),
                            elevation: 0,
                            child: IconButton(
                              icon: const Icon(Icons.arrow_back, color: _ink, size: 22),
                              tooltip: 'Kembali',
                              onPressed: _loading ? null : () => Navigator.pop(context),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Buat akun baru,\nmulai melapor.',
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Divider(color: _teal.withOpacity(0.18)),
                        const SizedBox(height: 6),
                        const Text(
                          'Gunakan email aktif dan NIM/NIP kamu.',
                          style: TextStyle(fontSize: 13, color: _muted),
                        ),
                        const SizedBox(height: 22),

                        _field(
                          controller: _nama,
                          hint: 'Nama lengkap',
                          icon: Icons.person_outline,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.length < 3) return 'Nama minimal 3 karakter';
                            if (t.length > 60) return 'Nama terlalu panjang';
                            if (!RegExp(r"^[\p{L} .,'-]+$", unicode: true).hasMatch(t)) {
                              return 'Nama hanya boleh berisi huruf';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _card(
                          DropdownButtonFormField<String>(
                            value: _jenisAkun,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: _muted),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(_radius),
                            style: const TextStyle(fontSize: 14, color: _ink),
                            decoration: _decoration(
                              hint: 'Jenis akun',
                              icon: Icons.school_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'mahasiswa',
                                child: Text('Mahasiswa'),
                              ),
                              DropdownMenuItem(
                                value: 'pegawai',
                                child: Text('Dosen / Pegawai'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _jenisAkun = value;
                                  _nimNip.clear();
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 14),

                        _field(
                          controller: _nimNip,
                          hint: _isMahasiswa ? 'NIM' : 'NIP (opsional)',
                          icon: Icons.badge_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(_isMahasiswa ? 9 : 18),
                          ],
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (_isMahasiswa) {
                              if (t.length != 9) return 'NIM harus 9 digit';
                            } else if (t.isNotEmpty && t.length < 8) {
                              return 'NIP minimal 8 digit';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _field(
                          controller: _email,
                          hint: 'Email aktif',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'Email wajib diisi';
                            if (!AuthService.isValidEmail(t)) {
                              return 'Format email tidak valid';
                            }
                            return null;
                          },
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(8, 6, 8, 0),
                          child: Text(
                            'Boleh email kampus atau pribadi. Tautan verifikasi dikirim ke sini.',
                            style: TextStyle(fontSize: 11, color: _muted),
                          ),
                        ),
                        const SizedBox(height: 14),

                        _field(
                          controller: _password,
                          hint: 'Kata sandi',
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                          suffix: IconButton(
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _muted,
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscure = !_obscure),
                          ),
                          validator: (v) {
                            if (v == null || v.length < 6) {
                              return 'Kata sandi minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),

                        _field(
                          controller: _confirmPassword,
                          hint: 'Konfirmasi kata sandi',
                          icon: Icons.lock_outline,
                          obscure: _obscure,
                          validator: (v) {
                            if (v == null || v.isEmpty) {
                              return 'Konfirmasi kata sandi wajib diisi';
                            }
                            if (v != _password.text) return 'Kata sandi tidak sama';
                            return null;
                          },
                        ),
                        const SizedBox(height: 26),

                        FilledButton(
                          onPressed: _loading ? null : _register,
                          style: FilledButton.styleFrom(
                            backgroundColor: _teal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            elevation: 0,
                            shape: shape,
                          ),
                          child: _loading
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Daftar',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Sudah punya akun?',
                                style: TextStyle(fontSize: 12, color: _muted)),
                            TextButton(
                              onPressed: _loading ? null : () => Navigator.pop(context),
                              style: TextButton.styleFrom(
                                foregroundColor: _teal,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              ),
                              child: const Text(
                                'Masuk',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}