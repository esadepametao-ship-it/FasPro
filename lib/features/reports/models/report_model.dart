
import 'package:cloud_firestore/cloud_firestore.dart';

class ReportModel {
  final String? id;
  final String uidPelapor;
  final String namaPelapor;
  final String judul;
  final String deskripsi;
  final String kategori;
  final String gedung;
  final String ruangan;
  final String? fotoUrl;
  final String status;
  final DateTime? createdAt;

  ReportModel({
    this.id,
    required this.uidPelapor,
    required this.namaPelapor,
    required this.judul,
    required this.deskripsi,
    required this.kategori,
    required this.gedung,
    required this.ruangan,
    this.fotoUrl,
    this.status = 'menunggu_verifikasi',
    this.createdAt,
  });

  // Mengubah data laporan menjadi Map untuk Firestore
  Map<String, dynamic> toMap() {
    return {
      'uidPelapor': uidPelapor,
      'namaPelapor': namaPelapor,
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'gedung': gedung,
      'ruangan': ruangan,
      'fotoUrl': fotoUrl,
      'status': status,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Mengambil data laporan dari Firestore
  factory ReportModel.fromMap(
    Map<String, dynamic> map, {
    String? documentId,
  }) {
    final timestamp = map['createdAt'];

    return ReportModel(
      id: documentId,
      uidPelapor: map['uidPelapor'] ?? '',
      namaPelapor: map['namaPelapor'] ?? '',
      judul: map['judul'] ?? '',
      deskripsi: map['deskripsi'] ?? '',
      kategori: map['kategori'] ?? '',
      gedung: map['gedung'] ?? '',
      ruangan: map['ruangan'] ?? '',
      fotoUrl: map['fotoUrl'],
      status: map['status'] ?? 'menunggu_verifikasi',
      createdAt: timestamp is Timestamp
          ? timestamp.toDate()
          : null,
    );
  }
}
