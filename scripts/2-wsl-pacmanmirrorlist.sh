#!/bin/bash
#
# Create script to update Pacman mirrorlist.

set -o errexit -o nounset

cat << END > "${HOME}/.local/bin/update-pacman-mirrorlist"
#!/bin/bash
#
# Update Pacman mirrorlist.

set -o errexit -o nounset

sudo reflector @/etc/xdg/reflector/reflector.conf
END

chmod +x "${HOME}/.local/bin/update-pacman-mirrorlist"
