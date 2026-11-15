
#!/usr/bin/env bash
# File: scripts/05_backup_restore.sh
# Peran: Anggota 5 - Backup, Verifikasi Integritas (SHA256), dan Restore

SRC_DIR="/srv/proyek6a/shared"
BACKUP_DIR="/srv/proyek6a/backup"
RESTORE_DIR="/srv/proyek6a/restore_uji"
LOG_FILE="/srv/proyek6a/logs/operasional.log"
TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

# Fungsi pencatatan log
log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ANGGOTA-5] $1" | tee -a "$LOG_FILE"
}

# Validasi input
if [[ $# -lt 1 ]]; then
    echo "Usage: $0 {backup|test_pos|test_neg|reset}"
    exit 2
fi

ACTION="$1"

# Persiapan direktori
mkdir -p "$BACKUP_DIR" "$RESTORE_DIR" "$(dirname "$LOG_FILE")"

case "$ACTION" in

    backup)
        if [[ ! -d "$SRC_DIR" ]]; then
            log_msg "ERROR: Direktori sumber $SRC_DIR tidak ditemukan!"
            exit 1
        fi

        ARCHIVE_FILE="$BACKUP_DIR/backup_shared_${TIMESTAMP}.tar.gz"
        CHECKSUM_FILE="${ARCHIVE_FILE}.sha256"

        # Membuat arsip backup
        if ! tar -czf "$ARCHIVE_FILE" -C "$SRC_DIR" .; then
            log_msg "ERROR: Proses pembuatan arsip backup gagal!"
            exit 1
        fi

        # Membuat checksum SHA-256
        if ! sha256sum "$ARCHIVE_FILE" > "$CHECKSUM_FILE"; then
            log_msg "ERROR: Pembuatan checksum gagal!"
            exit 1
        fi

        # Membuat salinan backup terbaru
        cp -f "$ARCHIVE_FILE" "$BACKUP_DIR/latest_backup.tar.gz"
        sha256sum "$BACKUP_DIR/latest_backup.tar.gz" > "$BACKUP_DIR/latest_backup.tar.gz.sha256"

        log_msg "BACKUP BERHASIL: Arsip $(basename "$ARCHIVE_FILE") dan checksum SHA256 dibuat."
        exit 0
        ;;

    test_pos)
        # Memastikan backup terbaru tersedia
        if [[ ! -f "$BACKUP_DIR/latest_backup.tar.gz" ]]; then
            log_msg "Backup belum tersedia. Membuat backup terlebih dahulu."
            "$0" backup || exit 1
        fi

        log_msg "UJI POSITIF: Verifikasi checksum dan restore dari latest_backup.tar.gz"

        # Verifikasi integritas arsip
        if sha256sum -c "$BACKUP_DIR/latest_backup.tar.gz.sha256" >/dev/null 2>&1; then

            # Membersihkan direktori restore sebelum pengujian
            find "$RESTORE_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

            # Melakukan restore
            if ! tar -xzf "$BACKUP_DIR/latest_backup.tar.gz" -C "$RESTORE_DIR"; then
                log_msg "HASIL POSITIF GAGAL: Proses ekstraksi arsip gagal!"
                exit 1
            fi

            # Memeriksa kesesuaian isi sumber dan hasil restore
            if diff -qr "$SRC_DIR" "$RESTORE_DIR" >/dev/null 2>&1; then
                log_msg "HASIL POSITIF LULUS: Integritas cocok dan seluruh berkas dipulihkan sesuai isi asli (exit 0)."
                ls -la "$RESTORE_DIR"
                exit 0
            else
                log_msg "HASIL POSITIF GAGAL: Isi berkas hasil restore tidak sesuai!"
                exit 1
            fi

        else
            log_msg "HASIL POSITIF GAGAL: Checksum backup asli tidak cocok!"
            exit 1
        fi
        ;;

    test_neg)
        # Memastikan backup tersedia
        if [[ ! -f "$BACKUP_DIR/latest_backup.tar.gz" ]]; then
            log_msg "Backup belum tersedia. Membuat backup terlebih dahulu."
            "$0" backup || exit 1
        fi

        CORRUPT_ARCHIVE="$BACKUP_DIR/corrupt_backup.tar.gz"
        CORRUPT_CHECKSUM="$BACKUP_DIR/corrupt_backup.tar.gz.sha256"

        # Menyalin arsip backup asli
        cp -f "$BACKUP_DIR/latest_backup.tar.gz" "$CORRUPT_ARCHIVE"

        # Membuat checksum sebelum arsip dirusak
        sha256sum "$CORRUPT_ARCHIVE" > "$CORRUPT_CHECKSUM"

        # Simulasi kerusakan/modifikasi pada arsip backup
        echo "DATA_RUSAK_KORUPSI" >> "$CORRUPT_ARCHIVE"

        log_msg "UJI NEGATIF: Mencoba restore dari arsip yang telah rusak ($CORRUPT_ARCHIVE)"

        # Memeriksa apakah kerusakan terdeteksi
        if sha256sum -c "$CORRUPT_CHECKSUM" >/dev/null 2>&1; then
            log_msg "HASIL NEGATIF GAGAL: Arsip rusak tidak terdeteksi oleh checksum!"
            exit 1
        else
            log_msg "HASIL NEGATIF LULUS: Kerusakan arsip terdeteksi (Checksum mismatch). Proses restore DIBATALKAN demi menjaga integritas data."
            exit 14
        fi
        ;;

    reset)
        # Membersihkan file simulasi corrupt dan hasil restore uji
        rm -f "$BACKUP_DIR/corrupt_backup.tar.gz" \
              "$BACKUP_DIR/corrupt_backup.tar.gz.sha256"

        find "$RESTORE_DIR" -mindepth 1 -maxdepth 1 -exec rm -rf -- {} +

        log_msg "RESET: Berkas simulasi corrupt dan direktori restore uji telah dibersihkan."
        exit 0
        ;;

    *)
        echo "Parameter tidak dikenal: $ACTION"
        echo "Gunakan {backup|test_pos|test_neg|reset}"
        exit 2
        ;;
esac
