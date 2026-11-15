
#!/usr/bin/env bash

SRC_DIR="/srv/proyek6a/shared"
BACKUP_DIR="/srv/proyek6a/backup"
RESTORE_DIR="/srv/proyek6a/restore_uji"
LOG_FILE="/srv/proyek6a/logs/operasional.log"

TIMESTAMP=$(date '+%Y%m%d_%H%M%S')

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ANGGOTA-5] $1" | tee -a "$LOG_FILE"
}

if [ $# -ne 1 ]; then
    echo "Gunakan: $0 {backup|test_pos|test_neg|reset}"
    exit 2
fi

mkdir -p "$BACKUP_DIR" "$RESTORE_DIR" "$(dirname "$LOG_FILE")"

case "$1" in

    backup)
        if [ ! -d "$SRC_DIR" ]; then
            log_msg "Folder shared tidak ditemukan."
            exit 1
        fi

        ARCHIVE="$BACKUP_DIR/backup_shared_${TIMESTAMP}.tar.gz"

        if ! tar -czf "$ARCHIVE" -C "$SRC_DIR" .; then
            log_msg "Backup gagal dibuat."
            exit 1
        fi

        if ! sha256sum "$ARCHIVE" > "$ARCHIVE.sha256"; then
            log_msg "Checksum gagal dibuat."
            exit 1
        fi

        cp -f "$ARCHIVE" "$BACKUP_DIR/latest_backup.tar.gz"
        sha256sum "$BACKUP_DIR/latest_backup.tar.gz" > "$BACKUP_DIR/latest_backup.tar.gz.sha256"

        log_msg "Backup berhasil dibuat."
        exit 0
        ;;

    test_pos)
        if [ ! -f "$BACKUP_DIR/latest_backup.tar.gz" ]; then
            bash "$0" backup || exit 1
        fi

        if sha256sum -c "$BACKUP_DIR/latest_backup.tar.gz.sha256" >/dev/null 2>&1; then

            rm -rf "$RESTORE_DIR"/*

            if ! tar -xzf "$BACKUP_DIR/latest_backup.tar.gz" -C "$RESTORE_DIR"; then
                log_msg "Restore gagal."
                exit 1
            fi

            for f in "$SRC_DIR"/*; do
                if [ -f "$f" ]; then
                    NAME=$(basename "$f")

                    if ! cmp -s "$f" "$RESTORE_DIR/$NAME"; then
                        log_msg "Isi file $NAME tidak sesuai."
                        exit 1
                    fi
                fi
            done

            log_msg "UJI POSITIF BERHASIL. Data berhasil dipulihkan."
            exit 0

        else
            log_msg "UJI POSITIF GAGAL. Checksum tidak cocok."
            exit 1
        fi
        ;;

    test_neg)
        if [ ! -f "$BACKUP_DIR/latest_backup.tar.gz" ]; then
            bash "$0" backup || exit 1
        fi

        cp -f "$BACKUP_DIR/latest_backup.tar.gz" "$BACKUP_DIR/corrupt_backup.tar.gz"

        sha256sum "$BACKUP_DIR/corrupt_backup.tar.gz" > "$BACKUP_DIR/corrupt_backup.tar.gz.sha256"

        echo "DATA_RUSAK" >> "$BACKUP_DIR/corrupt_backup.tar.gz"

        if sha256sum -c "$BACKUP_DIR/corrupt_backup.tar.gz.sha256" >/dev/null 2>&1; then
            log_msg "UJI NEGATIF GAGAL. Kerusakan tidak terdeteksi."
            exit 1
        else
            log_msg "UJI NEGATIF BERHASIL. Backup rusak terdeteksi dan restore ditolak."
            exit 14
        fi
        ;;

    reset)
        rm -f "$BACKUP_DIR/corrupt_backup.tar.gz"
        rm -f "$BACKUP_DIR/corrupt_backup.tar.gz.sha256"
        rm -rf "$RESTORE_DIR"/*

        log_msg "File pengujian berhasil dibersihkan."
        exit 0
        ;;

    *)
        echo "Perintah tidak dikenal."
        exit 2
        ;;
esac
