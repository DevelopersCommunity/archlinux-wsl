#!/bin/bash
#
# Sway installation.

set -o errexit -o nounset

readonly config_home=${XDG_CONFIG_HOME:-$HOME/.config}

sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm sway noto-fonts foot wayvnc pipewire pipewire-pulse \
  pipewire-jack pipewire-media-session
sudo pacman -S --noconfirm --asdeps dmenu wl-clipboard xorg-xwayland

mkdir -p "${config_home}/sway"
sway_config=$(cat /etc/sway/config)
sway_config=${sway_config/set \$mod Mod4/set \$mod Mod1}
echo "${sway_config/get_outputs/$'get_outputs\noutput HEADLESS-1 resolution 1600x900 position 1600,0'}" \
  > "${config_home}/sway/config"
if [[ $(cat /proc/sys/kernel/osrelease) =~ .*WSL2.* ]]; then
  echo "exec wayvnc 0.0.0.0" >> "${config_home}/sway/config"
else
  echo "exec wayvnc" >> "${config_home}/sway/config"
fi

cat << END >> "${HOME}/.bashrc"

if (( SHLVL == 1 )); then
  export PATH="\${HOME}/.local/bin":\${PATH}
fi
END

mkdir -p "${HOME}/.local/bin"
cat << END > "${HOME}/.local/bin/s"
#!/bin/bash
#
# Start Sway with a D-Bus session instance

cd "\${HOME}" || exit 1

if [[ -z "\${DBUS_SESSION_BUS_ADDRESS}" ]]; then
  XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland WLR_BACKENDS=headless \\
    dbus-run-session sway
else
  XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland WLR_BACKENDS=headless sway
fi
END

chmod +x "${HOME}/.local/bin/s"

scriptdir=$(dirname "$0")
readonly scriptdir
if [[ $(cat /proc/sys/kernel/osrelease) =~ .*WSL2.* ]]; then
  bash "${scriptdir}/2-2-wlroots.sh"
else
  bash "${scriptdir}/2-2-pulseaudio.sh"
  sudo reboot
fi
