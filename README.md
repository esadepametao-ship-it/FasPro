# FasPro – Facility Problem Reporting

> Report Problems, Improve Facilities.

## Deskripsi Singkat

FasPro (Facility Problem Reporting) merupakan aplikasi mobile berbasis Flutter yang dirancang untuk memudahkan mahasiswa, dosen, dan staf dalam melaporkan kerusakan fasilitas kampus.

Melalui aplikasi ini, pengguna dapat mengirimkan laporan kerusakan dengan menyertakan foto, deskripsi, serta lokasi fasilitas. Laporan yang masuk akan dikelola oleh admin dan diteruskan kepada teknisi untuk ditindaklanjuti.

FasPro bertujuan meningkatkan efektivitas pengelolaan fasilitas kampus serta mempermudah proses pelaporan, pemantauan, dan penanganan kerusakan.

## Anggota Tim

| Nama | NIM |
|------|-----|
| Claudya Vitalokha Sembiring | 241402020 |
| Lisdanoviati | 241402014 |
| Natali Desi Deryani Sembiring | 241402052 |
| Inrita Eza Kartika Depametou | 241402055 |
| Miranda Nainggolan | 241402125 |
| Vina Permata Sari | 241402026 |

## Rencana Fitur

1. **Login dan Register**
   Pengguna dapat membuat akun dan masuk ke aplikasi sesuai perannya (pelapor, admin fasilitas, teknisi).
2. **Pemilihan Lokasi Detail**
   Pengganti QR code: pelapor memilih nama gedung dan ruangan melalui dropdown bertingkat, lalu mengisi objek yang rusak (misalnya AC, proyektor, lampu) pada kolom teks.
3. **Pengaduan Kerusakan**
   Pelapor mengirim laporan dengan foto bukti, lokasi, objek yang rusak, dan deskripsi kerusakan.
4. **Laporan Anonim**
   Pelapor dapat menyembunyikan identitasnya dari teknisi dan pengguna lain. Identitas asli tetap dapat dilihat admin.
5. **Manajemen Laporan Admin**
   Admin memverifikasi laporan masuk, menentukan prioritas, dan menugaskan teknisi.
6. **Penanganan oleh Teknisi**
   Teknisi melihat tugas perbaikan, memperbarui status pengerjaan, mengunggah foto sebelum/sesudah perbaikan, lalu mengajukan konfirmasi selesai kepada admin.
7. **Verifikasi Penyelesaian oleh Admin**
   Admin memeriksa hasil pekerjaan teknisi dan menyatakan laporan selesai (Resolved) atau mengembalikannya untuk diperbaiki ulang.
8. **Status Laporan**
   Pelapor memantau perkembangan laporan melalui status Reported, Verified, Assigned, In Progress, dan Resolved.
9. **Riwayat Status Perbaikan**
   Setiap perubahan status dari teknisi dan verifikasi admin tercatat sebagai riwayat lengkap (waktu, pelaku, dan catatan).
10. **Riwayat Pelapor**
    Pelapor dapat melihat daftar laporan yang pernah dibuat beserta status penyelesaiannya.
11. **Riwayat Admin**
    Admin dapat melihat riwayat laporan dari setiap pelapor, riwayat pekerjaan setiap teknisi, dan riwayat pergantian teknisi pada suatu laporan.
12. **Notifikasi**
    Pengguna mendapat pemberitahuan setiap ada perubahan status atau penugasan baru.
    
## Teknologi yang Digunakan

- Flutter
- Dart
- Firebase (rencana integrasi)
- GitHub