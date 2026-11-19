#!/usr/bin/env bash

ssh_lokal() {
	local akun=$1
	shift
	sudo -H -u "$akun" ssh -o BatchMode=yes "$akun@127.0.0.1" "$@"
}

case "$1" in
setup)
		echo "admin_os ALL=(ALL) NOPASSWD: /bin/systemctl status smbd, /bin/systemctl status ssh, /bin/systemctl restart smbd, /bin/systemctl stop smbd, /bin/systemctl start smbd" | sudo tee /etc/sudoers.d/proyek6a_admin >/dev/null
		sudo chmod 440 /etc/sudoers.d/proyek6a_admin
		for u in admin_os user_ro; do
			sudo -u "$u" mkdir -p /home/$u/.ssh
			sudo -u "$u" ssh-keygen -t ed25519 -N "" -f /home/$u/.ssh/id_ed25519 <<< y >/dev/null 2>&1
			sudo -u "$u" cp /home/$u/.ssh/id_ed25519.pub /home/$u/.ssh/authorized_keys
			ssh-keyscan -H 127.0.0.1 | sudo -u "$u" tee /home/$u/.ssh/known_hosts >/dev/null 2>&1
			sudo chmod 700 /home/$u/.ssh
			sudo chmod 600 /home/$u/.ssh/authorized_keys
			sudo chmod 644 /home/$u/.ssh/known_hosts
		done
		echo "SETUP SSH: Sudoers dan SSH Key berhasil dibuat."
		;;
	test_pos)
		for layanan in ssh smbd; do
			ssh_lokal admin_os \
				"sudo -n /usr/bin/systemctl status $layanan --no-pager" || exit 1
		done 
		echo "LULUS: admin_os berhasil mengecek SSH dan Samaba lewat SSH."
		;;
		test_neg)
		hasil=$(ssh_lokal user_ro \
			'whoami && LC_ALL=C sudo -n /usr/bin/systemctl restart smbd' 2>&1)
		kode=$?
		printf '%s\n' "$hasil"

		if [[ $kode -eq 1 ]] &&
			grep -qx 'user_ro' <<< "$hasil" &&
			grep -Eq "afraid I can't do that|not allowed|not in the sudoers" <<< \
	"$hasil"; then
		echo "LULUS: user_ro berhasil login, lalu sudo menolak restart Samba."
		exit 13
		fi

		echo "GAGAL: penolakan sudo belum terbukti." >&2
		exit 1
		;; 
	simulasi_mati)
		sudo systemctl stop smbd || exit 1
		status_mati=$(systemctl is-active smbd)
		sudo systemctl start smbd || exit 1
		status_pulih=$(systemctl is-active smbd)
		echo "Setelah stop: $status_mati"
		echo "Setelah start: $status_pulih"
		[[ $status_mati == inactive && $status_pulih == active ]]
		;;
	reset)
		sudo systemctl start ssh smbd &&
			systemctl is-active ssh smbd
		;;
	*)
		echo "Penggunaan: $0 {test_pos|test-neg|simulasi_mati|reset}" >&2
		exit 2
		;;
esac

