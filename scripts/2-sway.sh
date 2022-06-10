#!/bin/bash
#
# Sway installation.

set -o errexit -o nounset

readonly config_home=${XDG_CONFIG_HOME:-${HOME}/.config}

if [[ -f /etc/systemd/system/pacman-init.service ]]; then
  until systemctl is-active pacman-init.service; do
    sleep 1
  done
  sudo systemctl disable pacman-init.service
  sudo rm /etc/systemd/system/pacman-init.service
fi

sudo pacman -Syu --noconfirm
sudo pacman -S --asdeps --needed --noconfirm noto-fonts noto-fonts-cjk foot \
  dmenu xorg-xwayland swaybg wl-clipboard wireplumber pipewire pipewire-jack
sudo pacman -S --needed --noconfirm sway wayvnc git chromium upower \
  neovim bash-completion base-devel

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

# Append "\$1" to \$PATH when not already in.
append_path () {
  case ":\${PATH}:" in
    *:"\$1":*)
      ;;
    *)
      PATH="\${PATH:+\${PATH}:}\$1"
  esac
}

# Prepend "\$1" to \$PATH when not already in.
prepend_path () {
  case ":\${PATH}:" in
    *:"\$1":*)
      ;;
    *)
      PATH="\$1\${PATH:+:\${PATH}}"
  esac
}

export EDITOR=/bin/nvim
export CHROME_BIN=/bin/chromium

prepend_path "\${HOME}/.local/bin"
END

mkdir -p "${HOME}/.local/bin"
cat << END > "${HOME}/.local/bin/s"
#!/bin/bash
#
# Start Sway with a D-Bus session instance

set -o errexit -o nounset

cd "\${HOME}" || exit 1

if [[ -z "\${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland WLR_BACKENDS=headless \\
    WLR_LIBINPUT_NO_DEVICES=1 dbus-run-session sway
else
  XDG_CURRENT_DESKTOP=sway XDG_SESSION_TYPE=wayland WLR_BACKENDS=headless \\
    WLR_LIBINPUT_NO_DEVICES=1 sway
fi
END

chmod +x "${HOME}/.local/bin/s"

mkdir -p "${config_home}/foot"
cp /etc/xdg/foot/foot.ini "${config_home}/foot/"

scriptdir=$(dirname "$0")
readonly scriptdir
if [[ $(cat /proc/sys/kernel/osrelease) =~ .*WSL2.* ]]; then
  bash "${scriptdir}/2-wsl-wlroots.sh"
  bash "${scriptdir}/2-wsl-pacmanmirrorlist.sh"
else
  bash "${scriptdir}/2-hyperv-pulseaudio.sh"
  sudo reboot
fi

echo "--ozone-platform-hint=auto" >> "${config_home}/chromium-flags.conf"
