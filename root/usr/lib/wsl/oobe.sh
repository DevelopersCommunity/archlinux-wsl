#!/bin/bash
#
# Out of box experience script

set -ue

DEFAULT_UID='1000'

echo 'Please create a default UNIX user account. The username does not need to match your Windows username.'
echo 'For more information visit: https://aka.ms/wslusers'

if getent passwd "${DEFAULT_UID}" >/dev/null; then
  echo 'User account already exists, skipping creation'
  exit 0
fi

# https://man.archlinux.org/man/machine-id.5
systemd-machine-id-setup --commit
# https://wiki.archlinux.org/title/Reflector
systemctl enable reflector.timer
# https://learn.microsoft.com/azure/virtual-machines/linux/time-sync#chrony
systemctl enable chronyd.service

# Initialize and populate the pacman keyring
# https://wiki.archlinux.org/title/Pacman/Package_signing#Initializing_the_keyring
pacman-key --init
pacman-key --populate archlinux
pacman -S --noconfirm --needed archlinux-keyring

while true; do
  # Prompt for the username
  read -rp 'Enter new UNIX username: ' username

  # Create the user
  if useradd --uid "${DEFAULT_UID}" --create-home --user-group --groups wheel "${username}"; then
    while ! passwd "${username}"; do
      while true; do
        read -rp 'Try again? [y/N] ' try_again
        case "${try_again}" in
          [yY])
            continue 2
            ;;
          "" | [nN])
            break 2
            ;;
          *)
            continue
            ;;
        esac
      done
    done
    break
  else
    userdel "${username}"
  fi
done
