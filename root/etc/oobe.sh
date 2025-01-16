#!/bin/bash
#
# Out of box experience script

set -ue

/bin/dbus-uuidgen --ensure=/etc/machine-id
/bin/systemctl enable reflector.timer
/bin/systemctl enable chronyd.service

/bin/pacman-key --init
/bin/pacman-key --populate archlinux
/bin/pacman -S --noconfirm --needed archlinux-keyring

DEFAULT_UID='1000'

echo 'Please create a default UNIX user account. The username does not need to match your Windows username.'
echo 'For more information visit: https://aka.ms/wslusers'

if getent passwd "${DEFAULT_UID}" >/dev/null; then
  echo 'User account already exists, skipping creation'
  exit 0
fi

while true; do
  # Prompt for the username
  read -rp 'Enter new UNIX username: ' username

  # Create the user
  if /bin/useradd --uid "${DEFAULT_UID}" --create-home --user-group --groups wheel "${username}"; then
    break
  else
    /bin/userdel "${username}"
  fi
done

while ! /bin/passwd "${username}"; do
  :
done
