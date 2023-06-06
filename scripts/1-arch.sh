#!/bin/bash
#
# Prepare Arch Linux WSL image.

set -eu

pacman=$(cat /etc/pacman.conf)
pacman="${pacman/NoProgressBar/\#NoProgressBar}"
echo "${pacman%$'\[options\]\nNoExtract*'}" >/etc/pacman.conf

pacman -Syu --noconfirm
pacman -S --noconfirm chrony reflector sudo

visudo=$(mktemp -q)
cat <<END >"${visudo}"
#!/bin/bash
#
# Add wheel group to sudoers.

set -eu

echo "%wheel ALL=(ALL:ALL) ALL" > "\$2"
END

chmod +x "${visudo}"
(EDITOR="${visudo}" bash -c "visudo -f /etc/sudoers.d/01_wheel")
rm "${visudo}"

chrony_conf=$(cat /etc/chrony.conf)
chrony_conf=${chrony_conf/pool 2.arch.pool.ntp.org iburst/; pool 2.arch.pool.ntp.org iburst}
chrony_conf=${chrony_conf/ntsdumpdir \/var\/lib\/chrony/; ntsdumpdir \/var\/lib\/chrony}
chrony_conf=${chrony_conf/makestep 1.0 3/makestep 1.0 -1}
chrony_conf=${chrony_conf/! local stratum 10/local stratum 2}
chrony_conf=${chrony_conf/rtcsync/; rtcsync}
echo "${chrony_conf}" >/etc/chrony.conf
echo "refclock PHC /dev/ptp_hyperv poll 3 dpoll -2 offset 0" >>/etc/chrony.conf

locale_gen=$(cat /etc/locale.gen)
echo "${locale_gen/\#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8}" >/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

cat <<END >/etc/wsl.conf
[boot]
systemd=true
END

pacman -Scc --noconfirm
rm -rf /etc/pacman.d/gnupg/
