#!/bin/bash
#
# Out of box experience script

set -ue

# https://man.archlinux.org/man/machine-id.5.en
/bin/systemd-machine-id-setup --commit
# https://wiki.archlinux.org/title/Reflector
/bin/systemctl enable reflector.timer
# https://learn.microsoft.com/azure/virtual-machines/linux/time-sync#chrony
/bin/systemctl enable chronyd.service

# Initialize and populate the pacman keyring
# https://wiki.archlinux.org/title/Pacman/Package_signing#Initializing_the_keyring
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

# Apply systemd recommendations
# http://learn.microsoft.com/windows/wsl/build-custom-distro#systemd-recommendations
su -c "mkdir -p \"\${HOME}/.config/systemd/user\"" - "${username}"
su -c "ln -s /dev/null \"\${HOME}/.config/systemd/user/systemd-tmpfiles-clean.service\"" - "${username}"
su -c "ln -s /dev/null \"\${HOME}/.config/systemd/user/systemd-tmpfiles-clean.timer\"" - "${username}"
su -c "ln -s /dev/null \"\${HOME}/.config/systemd/user/systemd-tmpfiles-setup.service\"" - "${username}"
