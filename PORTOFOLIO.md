---
ANGGOTA 2 — MOH CANDRA AHNAF FADHILA (2510512030)
---

# Portofolio Individu Proyek Akhir Sistem Operasi

## 1. Identitas
- Nama: Moh Candra Ahnaf Fadhila
- NIM: 2510512030
- Kelompok: Kelompok 6A
- Pilihan Proyek: 6A — Server Berkas Bersama dengan Backup dan Audit Akses
- Peran: Anggota 2 (Konfigurasi Samba dan Pengujian Akses Klien)

## 2. Asal Proyek
- Tautan Repository Utama Kelompok: https://github.com/fadhila277/proyek6a-so
- Tautan Repository Pribadi (Host Utama): https://github.com/fadhila277/proyek6a-so
- Daftar Anggota Kelompok:
  1. Muhammad Irsyad Athala Pasya (2510512024) — User, Group, dan Permission
  2. Moh Candra Ahnaf Fadhila (2510512030) — Samba dan Klien
  3. Sastia Rahmadani Azzahra (2510512018) — Hak Pembaca (Read-Only)
  4. Muhammad Mahmud Mahfuz (2510512004) — Administrasi SSH
  5. Ruth Keysha Putri Lase (2510512012) — Backup dan Restore
  6. Salvito Maryanto (2510512034) — Monitoring, Log, Laporan, dan Docker

## 3. Kontribusi Pribadi
Sebagai Anggota 2, kontribusi teknis dan analisis yang saya kerjakan meliputi:
- Menyusun konfigurasi file sharing Samba [proyek6a_share] pada berkas config/smb.conf.snippet yang mengarah ke /srv/proyek6a/shared dengan pembatasan akses berbasis grup (valid users = @operator @pembaca, read only = yes, write list = @operator).
- Mengembangkan dan menguji skrip otomasi scripts/02_samba_client.sh dengan parameter --setup, --test-pos, --test-neg, dan --reset.
- Melakukan pengujian integrasi akses klien menggunakan smbclient serta mendokumentasikan bukti uji pada evidence/02_samba_client.log dan evidence/bukti_anggota2.txt.

## 4. Bukti Kontribusi
- Skrip Utama: scripts/02_samba_client.sh
- Konfigurasi: config/smb.conf.snippet
- Log dan Bukti Uji: evidence/02_samba_client.log dan evidence/bukti_anggota2.txt
- Riwayat Commit: https://github.com/fadhila277/proyek6a-so/commits/main

## 5. Skenario Pengujian Individu
- Tujuan: Memastikan layanan Samba (smbd) hanya mengizinkan akun yang terdaftar dan tergabung dalam grup berwenang (operator/pembaca), serta menolak akun di luar grup (user_luar).
- Prasyarat / Kondisi Awal:
  Direktori /srv/proyek6a/shared dan akun Linux (user_op, user_ro, user_luar) telah disiapkan oleh Anggota 1. Konfigurasi [proyek6a_share] terpasang di /etc/samba/smb.conf, akun user_op dan user_ro aktif di database smbpasswd, serta layanan smbd berstatus active.
- Langkah Uji Positif (--test-pos):
  Menjalankan ./scripts/02_samba_client.sh --test-pos yang mengeksekusi smbclient //127.0.0.1/proyek6a_share -U user_op%Proyek6A_2026 -c "ls".
  Hasil Aktual: Koneksi diterima, daftar berkas (dokumen_unit_1.txt hingga dokumen_unit_3.txt) tampil, dan skrip menghasilkan exit status 0.
- Langkah Uji Negatif (--test-neg):
  Menjalankan ./scripts/02_samba_client.sh --test-neg yang mengeksekusi smbclient //127.0.0.1/proyek6a_share -U user_luar%Proyek6A_2026 -c "ls".
  Hasil Aktual: Koneksi ditolak dengan pesan tree connect failed: NT_STATUS_ACCESS_DENIED dan skrip menghasilkan exit status 13.
- Verifikasi dan Pemulihan (--reset):
  Memeriksa catatan waktu dan hasil uji pada evidence/02_samba_client.log, lalu menjalankan sudo ./scripts/02_samba_client.sh --reset untuk me-restart layanan smbd kembali ke kondisi normal.

## 6. Analisis Konsep Sistem Operasi
- Autentikasi: Samba mengelola database kredensial terpisah dari /etc/shadow Linux melalui smbpasswd/pdbedit. Klien wajib melewati tahap verifikasi identitas SMB sebelum sesi akses diberikan.
- Otorisasi dan Proteksi Berkas: Parameter valid users dan write list pada Samba bekerja berlapis di atas permission dan ACL sistem berkas Linux (chmod 2770 SetGID). Meskipun protokol jaringan mengizinkan akses, kernel Linux tetap menegakkan hak akses terketat pada tingkat sistem berkas.
- Proses Layanan dan I/O: Daemon smbd berjalan sebagai proses layanan latar belakang (background service) yang dikelola systemd, mendengarkan port TCP 445, dan melayani permintaan baca/tulis I/O berkas dari klien secara terisolasi.

## 7. Kendala dan Penyelesaian
- Kendala: Akun Linux baru (user_op dan user_ro) awalnya gagal melakukan autentikasi Samba karena belum terdaftar di database password Samba, serta perintah smbclient yang gagal menghasilkan kode keluar umum (1) sehingga sulit dibedakan dari kesalahan eksekusi skrip.
- Penyelesaian: Menambahkan otomasi pendaftaran akun non-interaktif (echo "$SMB_PASS"; echo "$SMB_PASS") | smbpasswd -s -a "$u" pada blok --setup, serta menetapkan exit status 13 (EACCES / Permission denied) secara eksplisit ketika penolakan akses pada uji negatif berhasil terdeteksi.

## 8. Refleksi
- Hal yang Sudah Dikuasai: Konfigurasi file sharing Samba berbasis grup, sinkronisasi akun Samba dengan pengguna Linux, pengujian akses otomatis menggunakan smbclient, serta pengelolaan exit status dan pencatatan log pada skrip Bash.
- Hal yang Masih Perlu Dipelajari: Penerapan enkripsi lalu lintas jaringan SMB3 secara menyeluruh serta integrasi autentikasi terpusat menggunakan LDAP/Active Directory untuk skala infrastruktur yang lebih besar.

---
ANGGOTA 3 — SASTIA RAHMADANI AZZAHRA (2510512018)
---

Portofolio Individu Proyek Akhir Sistem Operasi

1. Identitas
* Nama: Sastia Rahmadani Azzahra
* NIM: 2510512018
* Peran: Anggota 3 (Verifikasi Hak Pembaca / Read-Only dan Audit Akses)

2. Asal Proyek
* Tautan Repository Utama Kelompok: https://github.com/fadhila277/proyek6a-so
* Tautan Repository Pribadi (Fork): https://github.com/r4innnyyyy/proyek6a-so
* Daftar Anggota Kelompok:
  1. Muhammad Irsyad Athala Pasya (2510512024) — User, Group, dan Permission
  2. Moh Candra Ahnaf Fadhila (2510512030) — Samba dan Klien
  3. Sastia Rahmadani Azzahra (2510512018) — Hak Pembaca (Read-Only)
  4. Muhammad Mahmud Mahfuz (2510512004) — Administrasi SSH
  5. Ruth Keysha Putri Lase (2510512012) — Backup dan Restore
  6. Salvito Maryanto (2510512034) — Monitoring, Log, Laporan, dan Docker

3. Kontribusi Pribadi
Sebagai Anggota 3, kontribusi teknis dan analisis yang saya kerjakan meliputi:
* Mengembangkan dan menguji skrip otomasi scripts/03_hak_pembaca.sh dengan mode pengujian test_pos, test_neg, dan reset
* Melakukan pengujian hak akses pembaca (user_ro / grup pembaca) terhadap berkas /srv/proyek6a/shared/dokumen_unit_1.txt menggunakan skenario uji positif dan uji negatif
* Mendokumentasikan hasil pengujian, rincian hak akses/ACL, dan audit trail ke dalam evidence/anggota3_audit.log serta berkas bukti pengujian di folder evidence/

4. Bukti Kontribusi
* Skrip Utama: scripts/03_hak_pembaca.sh
* Log Audit: evidence/anggota3_audit.log
* Bukti Pengujian & ACL: evidence/ (berkas bukti pengujian Anggota 3)
* Riwayat Commit: https://github.com/r4innnyyyy/proyek6a-so/commits/main

5. Skenario Pengujian Individu
* Tujuan: Memastikan akun pembaca (user_ro) hanya memiliki izin baca (read-only) pada berkas /srv/proyek6a/shared/dokumen_unit_1.txt serta ditolak saat mencoba memodifikasi atau menghapus berkas
* Prasyarat / Kondisi Awal:
  Direktori /srv/proyek6a/shared, berkas dokumen_unit_1.txt (pemilik admin_os, grup operator), aturan izin/ACL (termasuk group:pembaca:r-- dan other::---), serta akun user_ro telah disiapkan pada tahap setup awal
* Langkah Uji Positif (test_pos):
  Menjalankan ./scripts/03_hak_pembaca.sh test_pos untuk membaca isi berkas /srv/proyek6a/shared/dokumen_unit_1.txt sebagai user_ro
  Hasil Aktual: Isi berkas (DOKUMEN RESMI UNIT KERJA 6A - DOK-01) terbaca, tercatat HASIL POSITIF LULUS pada log, dan skrip menghasilkan exit status 0
* Langkah Uji Negatif (test_neg):
  Menjalankan ./scripts/03_hak_pembaca.sh test_neg untuk menguji percobaan modifikasi (menambah teks) dan penghapusan (rm -f) berkas /srv/proyek6a/shared/dokumen_unit_1.txt oleh user_ro
  Hasil Aktual: Seluruh percobaan tulis dan hapus ditolak sistem (Permission denied), tercatat sebagai AUDIT AKSES dan HASIL NEGATIF LULUS pada log, serta menghasilkan exit status 13
* Verifikasi dan Pemulihan (reset):
  Menjalankan ./scripts/03_hak_pembaca.sh reset untuk mencatat verifikasi keutuhan berkas dan memeriksa metadata serta izin berkas (/srv/proyek6a/shared/dokumen_unit_1.txt) melalui ls -l

6. Analisis Konsep Sistem Operasi
* Hak Akses POSIX dan ACL: Selain bit izin dasar (user, group, others), keberadaan tanda + pada mode berkas (-rw-rwx---+) menandakan penerapan Access Control List (ACL) untuk mengatur hak akses secara lebih spesifik (seperti group:pembaca:r-- dan pembatasan akses pihak luar other::---)
* Prinsip Least Privilege dan Negative Testing: Pembatasan user_ro agar hanya dapat membaca berkas menerapkan prinsip hak akses seminimal mungkin. Pengujian negatif memvalidasi bahwa aksi modifikasi dan penghapusan benar-benar diblokir oleh kernel/sistem berkas.
* Exit Status dan Audit Trail: Kode keluar 0 menandakan operasi berhasil, sedangkan kode keluar 13 merepresentasikan penolakan akses (Permission denied). Pencatatan berbasis stempel waktu (timestamp) pada log membantu pelacakan jejak audit pengujian

7. Kendala dan Penyelesaian
* Kendala: Saat menjalankan perintah yang memerlukan hak administratif atau autentikasi di terminal, eksekusi bisa tertahan apabila password sudo belum terotentikasi atau salah ketik, serta saat memeriksa isi folder secara langsung tanpa hak akses yang sesuai dapat muncul Permission denied
* Penyelesaian: Memastikan sesi autentikasi sudo aktif sebelum menjalankan pengujian skrip dan menggunakan skrip/perintah dengan hak akses yang sesuai agar verifikasi berjalan lancar serta keutuhan berkas tetap terjaga

8. Refleksi
* Hal yang Sudah Dikuasai: Pembacaan permission dan ACL berkas Linux, penyusunan skrip pengujian otomatis berbasis Bash dengan skenario uji positif/negatif, pembacaan exit status (0 dan 13), serta pencatatan log bukti pengujian
* Hal yang Masih Perlu Dipelajari: Manajemen kebijakan ACL pada direktori berskala besar, analisis log keamanan sistem secara lebih mendalam, serta integrasi audit akses lintas layanan server.


