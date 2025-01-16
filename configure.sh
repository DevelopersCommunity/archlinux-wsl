#!/bin/bash
#
# Prepare Arch Linux WSL image.

set -eu

# Enable pacman progress bar and remove NoExtract options.
# https://gitlab.archlinux.org/archlinux/archlinux-docker/-/blob/master/scripts/make-rootfs.sh?ref_type=heads#L17
pacman=$(cat /etc/pacman.conf)
pacman="${pacman/NoProgressBar/\#NoProgressBar}"
echo "${pacman%\[options\]?NoExtract*}" >/etc/pacman.conf

pacman -Sy --noconfirm --disable-sandbox chrony reflector sudo

# Grant sudo access to the wheel group.
# https://wiki.archlinux.org/title/Sudo#Using_visudo
visudo_editor=$(mktemp -q)
cat <<END >"${visudo_editor}"
#!/bin/bash
#
# Add wheel group to sudoers.

set -eu

echo "%wheel ALL=(ALL:ALL) ALL" > "\$2"
END

chmod +x "${visudo_editor}"
(EDITOR="${visudo_editor}" bash -c "visudo -f /etc/sudoers.d/01_wheel")
rm "${visudo_editor}"

# Enable chrony to synchronize time with the Hyper-V PTP clock source.
# https://learn.microsoft.com/en-us/azure/virtual-machines/linux/time-sync#chrony
chrony_conf=$(cat /etc/chrony.conf)
chrony_conf=${chrony_conf/pool 2.arch.pool.ntp.org iburst/; pool 2.arch.pool.ntp.org iburst}
chrony_conf=${chrony_conf/ntsdumpdir \/var\/lib\/chrony/; ntsdumpdir \/var\/lib\/chrony}
chrony_conf=${chrony_conf/makestep 1.0 3/makestep 1.0 -1}
chrony_conf=${chrony_conf/rtcsync/; rtcsync}
echo "${chrony_conf}" >/etc/chrony.conf
echo "refclock PHC /dev/ptp_hyperv poll 3 dpoll -2 offset 0 stratum 2" >>/etc/chrony.conf

# Generate the en_US.UTF-8 locale.
# https://wiki.archlinux.org/title/Installation_guide#Localization
locale_gen=$(cat /etc/locale.gen)
echo "${locale_gen/\#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8}" >/etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

# Clean the package cache.
# https://wiki.archlinux.org/title/Pacman#Cleaning_the_package_cache
pacman -Scc --noconfirm --disable-sandbox
# Reset pacman keys. The default keys will be added by the oobe script on first run.
# https://wiki.archlinux.org/title/Pacman/Package_signing#Resetting_all_the_keys
rm -rf /etc/pacman.d/gnupg/
