import 'package:flutter/material.dart';

class ReportFormPage extends StatelessWidget {
  const ReportFormPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Laporan'),
      ),
      body: const Center(
        child: Text('Form Laporan Kerusakan'),
      ),
    );
  }
}
