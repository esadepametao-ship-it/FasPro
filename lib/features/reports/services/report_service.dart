
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/report_model.dart';

class ReportService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // Menyimpan laporan baru ke Firestore
  Future<String> createReport(ReportModel report) async {
    try {
      final docRef = await _firestore
          .collection('reports')
          .add(report.toMap());

      return docRef.id;
    } catch (e) {
      throw Exception('Gagal menyimpan laporan: $e');
    }
  }

  // Mengambil seluruh laporan milik seorang pelapor
  Stream<List<ReportModel>> getReportsByUser(String uid) {
    return _firestore
        .collection('reports')
        .where('uidPelapor', isEqualTo: uid)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ReportModel.fromMap(
          doc.data(),
          documentId: doc.id,
        );
      }).toList();
    });
  }

  // Mengambil detail satu laporan
  Future<ReportModel?> getReportById(String reportId) async {
    final doc = await _firestore
        .collection('reports')
        .doc(reportId)
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return ReportModel.fromMap(
      doc.data()!,
      documentId: doc.id,
    );
  }
}
