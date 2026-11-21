import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:faspro/core/theme/app_colors.dart';
import 'package:faspro/features/auth/services/auth_service.dart';
import 'package:faspro/features/auth/screens/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const _teal = AppColors.primary;
  static const _tealDark = AppColors.primaryDark;
  static const _ink = AppColors.ink;
  static const _muted = AppColors.muted;
  static const _radius = 18.0;

  final _formKey = GlobalKey<FormState>();
  final _identifier = TextEditingController(); // NIM/NIP atau email
  final _password = TextEditingController();
  final _auth = AuthService();

  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;

  bool get _busy => _loading || _googleLoading;

  @override
  void dispose() {
    _identifier.dispose();
    _password.dispose();
    super.dispose();
  }

  String _errorMessage(Object error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'invalid-credential':
          return 'NIM/NIP/email atau kata sandi salah.';
        case 'wrong-password':
          return 'Kata sandi salah.';
        case 'invalid-email':
          return 'Format email tidak valid.';
        case 'too-many-requests':
          return 'Terlalu banyak percobaan. Coba lagi nanti.';
        case 'network-request-failed':
          return 'Tidak ada koneksi internet.';
        default:
          return error.message ?? 'Terjadi kesalahan saat login.';
      }
    }
    return error.toString().replaceFirst('Exception: ', '');
  }

  void _snack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<void> _showNotice(String message, {bool success = false}) async {
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
                success ? Icons.check_circle : Icons.error_outline,
                color: success ? Colors.green : Colors.red,
                size: 52,
              ),
              const SizedBox(height: 14),
              Text(
                success ? 'Berhasil!' : 'Login Gagal',
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      await _auth.login(
        identifier: _identifier.text,
        password: _password.text,
      );
      // AuthGate otomatis pindah ke halaman sesuai role.
    } catch (e) {
      await _showNotice(_errorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }


  /// True kalau user menutup jendela pilih akun Google.
  bool _isCancelled(Object e) {
    final m = e.toString().toLowerCase();
    return m.contains('canceled') || m.contains('cancelled');
  }

  Future<void> _google() async {
    setState(() => _googleLoading = true);

    try {
      await _auth.signInWithGoogle();
      // Sukses: AuthGate otomatis pindah ke halaman sesuai role.
    } catch (e) {
      // User membatalkan: tidak perlu notifikasi (finally tetap jalan).
      if (_isCancelled(e)) return;

      _snack(_errorMessage(e));
    } finally {
      if (mounted) setState(() => _googleLoading = false);
    }
  }


  Future<void> _resetPassword() async {
    if (_identifier.text.trim().isEmpty) {
      _snack('Masukkan NIM/NIP atau email terlebih dahulu.');
      return;
    }
    try {
      await _auth.resetPassword(_identifier.text);
      _snack('Link reset password sudah dikirim ke email kamu.');
    } catch (e) {
      _snack(_errorMessage(e));
    }
  }

  /// Kolom input putih dengan bayangan lembut, tanpa garis tepi.
  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
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
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscure,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: _ink),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(fontSize: 14, color: _muted),
          prefixIcon: Icon(icon, color: _teal, size: 22),
          suffixIcon: suffix,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: const BorderSide(color: _teal, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide(color: Colors.red.shade700),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(_radius),
            borderSide: BorderSide(color: Colors.red.shade700, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _spinner(Color color) => SizedBox(
        height: 22,
        width: 22,
        child: CircularProgressIndicator(strokeWidth: 2.2, color: color),
      );

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
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _Logo(),
                        const SizedBox(height: 40),
                        const Text(
                          'Laporkan masalah,\nperbaiki fasilitas.',
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.25,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Divider(color: _teal.withOpacity(0.18)),
                        const SizedBox(height: 22),

                        _field(
                          controller: _identifier,
                          hint: 'NIM / NIP / Email',
                          icon: Icons.person_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            final t = v?.trim() ?? '';
                            if (t.isEmpty) return 'NIM/NIP atau email wajib diisi';
                            if (t.contains('@')) {
                              return AuthService.isValidEmail(t)
                                  ? null
                                  : 'Format email tidak valid';
                            }
                            return AuthService.isValidNim(t)
                                ? null
                                : 'Masukkan NIM/NIP (angka) atau email';
                          },
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
                          validator: (v) =>
                              (v == null || v.isEmpty) ? 'Kata sandi wajib diisi' : null,
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _busy ? null : _resetPassword,
                            style: TextButton.styleFrom(
                              foregroundColor: _teal,
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .labelMedium
                                  ?.copyWith(fontSize: 12),
                            ),
                            child: const Text('Lupa kata sandi?'),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Tombol Masuk
                        FilledButton(
                          onPressed: _busy ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: _teal,
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(56),
                            elevation: 0,
                            shape: shape,
                          ),
                          child: _loading
                              ? _spinner(Colors.white)
                              : const Text(
                                  'Masuk',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(child: Divider(color: _teal.withOpacity(0.18))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 14),
                              child: Text('Atau',
                                  style: TextStyle(fontSize: 12, color: _muted)),
                            ),
                            Expanded(child: Divider(color: _teal.withOpacity(0.18))),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Tombol Google: putih, garis dan teks teal
                        OutlinedButton(
                          onPressed: _busy ? null : _google,
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _tealDark,
                            minimumSize: const Size.fromHeight(56),
                            side: BorderSide(color: _teal.withOpacity(0.5), width: 1.2),
                            shape: shape,
                          ),
                          child: _googleLoading
                              ? _spinner(_teal)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/google_logo.png',
                                      height: 22,
                                      // Dipakai selama logo belum dipasang.
                                      errorBuilder: (_, __, ___) =>
                                          const Icon(Icons.g_mobiledata, size: 32),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text(
                                      'Lanjutkan dengan Google',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                        ),

                        const Spacer(),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Belum punya akun?',
                                style: TextStyle(fontSize: 12, color: _muted)),
                            TextButton(
                              onPressed: _busy
                                  ? null
                                  : () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const RegisterPage(),
                                        ),
                                      ),
                              style: TextButton.styleFrom(
                                foregroundColor: _teal,
                                minimumSize: Size.zero,
                                padding: const EdgeInsets.symmetric(horizontal: 6),
                              ),
                              child: const Text(
                                'Daftar',
                                style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w700),
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

/// Logo sementara berupa tulisan. Ganti dengan Image.asset kalau logo sudah jadi.
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF0F766E),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.home_repair_service_outlined,
              color: Colors.white, size: 22),
        ),
        const SizedBox(width: 10),
        RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
            children: const [
              TextSpan(text: 'Fas', style: TextStyle(color: Color(0xFF0B4F4A))),
              TextSpan(text: 'Pro', style: TextStyle(color: Color(0xFF14A08F))),
            ],
          ),
        ),
      ],
    );
  }
}