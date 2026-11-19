# Proyek 6A Sistem Operasi

Server berkas bersama dengan backup dan audit akses menggunakan Ubuntu Server.

## Anggota kelompok

| Anggota | Nama | NIM | Tanggung jawab |
| :---: | :--- | :---: | :--- |
| 1 | Muhammad Irsyad Athala Pasya | 2510512024 | User, group, dan permission |
| 2 | Moh Candra Ahnaf Fadhila | 2510512030 | Samba dan klien |
| 3 | Sastia Rahmadani Azzahra | 2510512018 | Hak pembaca dan audit akses |
| 4 | Muhammad Mahmud Mahfuz | 2510512004 | Administrasi SSH dan layanan |
| 5 | Ruth Keysha Putri Lase | 2510512012 | Backup dan restore SHA-256 |
| 6 | Salvito Maryanto | 2510512034 | Monitoring, laporan, dan Docker |

## Matriks skenario pengujian

| ID | Penanggung jawab | Skenario positif | Skenario negatif |
| :---: | :---: | :--- | :--- |
| U1 | Anggota 1 | Operator menulis berkas bersama. | Pengguna luar mencoba menulis berkas. |
| U2 | Anggota 2 | Operator mengakses share Samba. | Pengguna luar mencoba mengakses share. |
| U3 | Anggota 3 | Pembaca membaca dokumen. | Pembaca mencoba mengubah dan menghapus dokumen. |
| U4 | Anggota 4 | Admin memeriksa layanan melalui SSH. | Pembaca mencoba me-restart Samba melalui SSH. |
| U5 | Anggota 5 | Restore memakai arsip dengan checksum valid. | Restore memakai salinan arsip yang rusak. |
| U6 | Anggota 6 | Container membaca laporan dari host. | Container mencoba menulis pada mount read-only. |

## Hasil pengujian

| ID | Hasil positif | Hasil negatif | Status | Bukti |
| :---: | :--- | :--- | :---: | :---: |
| U1 | Berkas berhasil dibuat.<br>Exit `0`. | Penulisan ditolak.<br>Exit `1` pada VM Mahmud. | ✅ Lulus | [Log](evidence/01_user_perm.log) |
| U2 | Isi share tampil.<br>Exit `0`. | `NT_STATUS_ACCESS_DENIED`.<br>Exit skrip `13`. | ✅ Lulus | [Log](evidence/bukti_anggota2.txt) |
| U3 | Isi dokumen terbaca.<br>Exit `0`. | Modifikasi dan penghapusan ditolak.<br>Exit skrip yang ditetapkan `13`. | ✅ Lulus | [Log](evidence/bukti_anggota3.txt) |
| U4 | Status layanan terbaca melalui SSH.<br>Exit `0`. | Restart oleh pembaca ditolak.<br>Exit skrip `13`. | ✅ Lulus | [Log](evidence/bukti_anggota4.txt) |
| U5 | Checksum cocok dan hasil restore sesuai sumber.<br>Exit `0`. | Checksum berbeda, restore dibatalkan.<br>Exit `14`. | ✅ Lulus | [Log](evidence/bukti_anggota5.txt) |
| U6 | Container berhasil membaca laporan.<br>Exit `0`. | Skrip mencatat penolakan dengan exit `0`.<br>Checksum sebelum dan sesudah sama. | 🟡 Pelengkapan bukti | [Log](evidence/bukti_anggota6.txt) |

### Pemulihan layanan Anggota 4

| Tahap | Hasil aktual |
| :--- | :--- |
| Menghentikan Samba | Status `inactive` |
| Menjalankan kembali Samba | Status `active` |
| Hasil simulasi | Exit `0` |

### Catatan hasil

- Penolakan akses yang sesuai merupakan keberhasilan skenario negatif.
- Kode keluar mengikuti implementasi masing-masing skrip.
- Anggota 6 perlu melengkapi bukti dengan pesan langsung `Read-only file system` dan kode keluar perintah Docker. Skrip saat ini menganggap kegagalan perintah Docker sebagai keberhasilan uji negatif.

## Dokumen pendukung

| Dokumen | Tautan |
| :--- | :--- |
| Spesifikasi VM pengujian | [Lihat spesifikasi](evidence/01_spesifikasi_vm.txt) |
| Laporan operasional | [Lihat laporan](output/laporan.txt) |
| Skrip seluruh anggota | [Buka folder scripts](scripts/) |
| Bukti pengujian | [Buka folder evidence](evidence/) |
