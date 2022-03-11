#!/bin/bash
#
# Prepare Arch Linux WSL image.

set -o errexit -o nounset

pacman=$(cat /etc/pacman.conf)
echo "${pacman%$'\[options\]\nNoExtract*'}" > /etc/pacman.conf

pacman -Syu --noconfirm
pacman -Sy --noconfirm sudo

visudo=$(mktemp -q)
cat << END > "${visudo}"
#!/bin/bash
#
# Add wheel group to sudoers.

set -o errexit -o nounset -o pipefail

echo "%wheel ALL=(ALL:ALL) ALL" > "\$2"
END

chmod +x "${visudo}"
(EDITOR="${visudo}" bash -c "visudo -f /etc/sudoers.d/01-wheel-group")
rm "${visudo}"
