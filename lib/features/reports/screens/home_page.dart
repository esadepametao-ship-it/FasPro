
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../shared/models/app_user.dart';
import '../../profile/services/profile_service.dart';
import '../services/report_service.dart';
import '../models/report_model.dart';
import 'report_form_page.dart';

class ReporterHomePage extends StatelessWidget {
  const ReporterHomePage({super.key});

  static const Color primaryGreen = Color(0xFF2E7D32);
  static const Color lightGreen = Color(0xFFE8F5E9);
  static const Color backgroundColor = Color(0xFFF7F9F7);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      backgroundColor: backgroundColor,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'FasPro',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: primaryGreen,
          ),
        ),
        actions: [
          // ICON NOTIFIKASI
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.black87,
            ),
            tooltip: 'Notifikasi',
          ),

          // ICON LOGOUT
          IconButton(
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
              } catch (e) {
                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Gagal logout. Silakan coba lagi.',
                    ),
                  ),
                );
              }
            },
            icon: const Icon(
              Icons.logout_rounded,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            tooltip: 'Logout',
          ),

          const SizedBox(width: 8),
        ],
      ),

      // BODY
      body: StreamBuilder<AppUser?>(
        stream: ProfileService().watchProfile(uid),
        builder: (context, profileSnapshot) {
          if (profileSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
              ),
            );
          }

          final user = profileSnapshot.data;

          if (user == null) {
            return const Center(
              child: Text('Data profil tidak ditemukan.'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreeting(user),
                const SizedBox(height: 24),
                _buildInfoCard(),
                const SizedBox(height: 24),
                _buildCreateReportButton(context),
                const SizedBox(height: 28),
                _buildReportSummary(uid),
                const SizedBox(height: 28),
                _buildRecentReports(uid),
              ],
            ),
          );
        },
      ),
    );
  }

  // GREETING / PROFIL PENGGUNA
  Widget _buildGreeting(AppUser user) {
    return Row(
      children: [
        CircleAvatar(
          radius: 27,
          backgroundColor: lightGreen,
          backgroundImage:
              user.fotoUrl != null && user.fotoUrl!.isNotEmpty
                  ? NetworkImage(user.fotoUrl!)
                  : null,
          child: user.fotoUrl == null || user.fotoUrl!.isEmpty
              ? const Icon(
                  Icons.person,
                  color: primaryGreen,
                  size: 30,
                )
              : null,
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Selamat datang,',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 13,
                ),
              ),
              Text(
                user.nama,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.nimNip,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // INFO CARD
  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.apartment_rounded,
            color: Colors.white,
            size: 34,
          ),
          SizedBox(height: 14),
          Text(
            'Laporkan Kerusakan Fasilitas',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bantu kami menjaga fasilitas kampus tetap nyaman '
            'dengan melaporkan kerusakan yang kamu temukan.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // BUTTON BUAT LAPORAN
  Widget _buildCreateReportButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ReportFormPage(),
            ),
          );
        },
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          'Buat Laporan Kerusakan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // RINGKASAN LAPORAN
  Widget _buildReportSummary(String uid) {
    return StreamBuilder<List<ReportModel>>(
      stream: ReportService().getReportsByUser(uid),
      builder: (context, snapshot) {
        final reports = snapshot.data ?? [];

        final waiting = reports
            .where((report) =>
                report.status == 'menunggu_verifikasi')
            .length;

        return Row(
          children: [
            Expanded(
              child: _summaryCard(
                'Total Laporan',
                reports.length.toString(),
                Icons.description_outlined,
                primaryGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                'Menunggu',
                waiting.toString(),
                Icons.hourglass_empty_rounded,
                Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  // SUMMARY CARD
  Widget _summaryCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // LAPORAN TERBARU
  Widget _buildRecentReports(String uid) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Laporan Terbaru',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 14),
        StreamBuilder<List<ReportModel>>(
          stream: ReportService().getReportsByUser(uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: primaryGreen,
                ),
              );
            }

            if (snapshot.hasError) {
              return const Text('Gagal memuat laporan.');
            }

            final reports = snapshot.data ?? [];

            if (reports.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 42,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Belum ada laporan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Laporan kerusakan yang kamu kirim '
                      'akan muncul di sini.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              );
            }

            final sortedReports = [...reports]
              ..sort((a, b) {
                return (b.createdAt ?? DateTime(2000))
                    .compareTo(a.createdAt ?? DateTime(2000));
              });

            return Column(
              children: sortedReports.take(5).map((report) {
                return _reportCard(report);
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  // REPORT CARD
  Widget _reportCard(ReportModel report) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: lightGreen,
            child: Icon(
              Icons.build_outlined,
              color: primaryGreen,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.judul,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${report.gedung} • ${report.ruangan}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  report.status.replaceAll('_', ' '),
                  style: const TextStyle(
                    color: Color(0xFFDA8B18),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
