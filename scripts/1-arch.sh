#!/bin/bash
#
# Prepare Arch Linux WSL image.

set -o errexit -o nounset

pacman=$(cat /etc/pacman.conf)
pacman="${pacman/NoProgressBar/\#NoProgressBar}"
echo "${pacman%$'\[options\]\nNoExtract*'}" > /etc/pacman.conf

pacman -Syu --noconfirm
pacman -S --noconfirm sudo reflector

visudo=$(mktemp -q)
cat << END > "${visudo}"
#!/bin/bash
#
# Add wheel group to sudoers.

set -o errexit -o nounset

echo "%wheel ALL=(ALL:ALL) ALL" > "\$2"
END

chmod +x "${visudo}"
(EDITOR="${visudo}" bash -c "visudo -f /etc/sudoers.d/01_wheel")
rm "${visudo}"

locale_gen=$(cat /etc/locale.gen)
echo "${locale_gen/\#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8}" > /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

cat << END > /etc/wsl.conf
[boot]
systemd=true
END

pacman -Scc --noconfirm
rm -rf /etc/pacman.d/gnupg/
