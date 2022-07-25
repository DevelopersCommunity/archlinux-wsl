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

pacman -Scc --noconfirm
rm -rf /etc/pacman.d/gnupg/
