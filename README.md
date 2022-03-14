# WSL Arch Linux Launcher

## Introduction

This is an [Arch Linux](https://archlinux.org) installer/launcher for the [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/windows/wsl/). This installer was built using the [WSL Distro Launcher Reference Implementation](https://github.com/microsoft/WSL-DistroLauncher).

## Image

The image used by this installer is based on the Arch Linux docker base image available in the [Arch Linux docker repository](https://gitlab.archlinux.org/archlinux/archlinux-docker/-/releases) with the following changes:

- `NoExtract` options removed from [/etc/pacman.conf](https://archlinux.org/pacman/pacman.conf.5.html).
- [sudo](https://archlinux.org/packages/core/x86_64/sudo/) and [reflector](https://archlinux.org/packages/community/any/reflector/) packages installed
- `wheel` group added to `sudoers`

The script used to make these changes is available in the [scripts](./scripts/1-arch.sh) directory.

```bash
#!/bin/bash
#
# Prepare Arch Linux WSL image.

set -o errexit -o nounset

pacman=$(cat /etc/pacman.conf)
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
```

## Installation

The Arch Linux installer is packaged with the [MSIX format](https://docs.microsoft.com/windows/msix/), and is available in the [releases page](https://github.com/DevelopersCommunity/WSL-DistroLauncher/releases) The package was signed with a self-signed certificate, you need to import it into one of your local machine certificate trusted store (for example, `Trusted People`) before executing the installer. Run the following PowerShell command to import it (you will need administrative privileges). The certificate is available in the [scripts](./scripts/DistroLauncher-Appx_TemporaryKey.crt) directory. After installing the package, you can remove it from your store.

```powershell
Import-Certificate `
    -FilePath .\DistroLauncher-Appx_TemporaryKey.crt `
    -CertStoreLocation cert:\LocalMachine\TrustedPeople
```

Besides creating the default user, the installation process also initializes the pacman [mirror list](https://wiki.archlinux.org/title/mirrors) and the [keyring](https://wiki.archlinux.org/title/Pacman/Package_signing#Resetting_all_the_keys).

## Post-installation

- [Configure pacman parallel downloads](https://wiki.archlinux.org/title/Pacman#Enabling_parallel_downloads)
- [Install a text editor](https://wiki.archlinux.org/title/Category:Text_editors)

## Sway window manager

It is possible to install and run the [Sway](https://swaywm.org/) tiling [Wayland](https://wayland.freedesktop.org/) compositor in your WSL environment, but we need to apply a small patch to the [wlroots library](https://gitlab.freedesktop.org/wlroots/wlroots/) to fix an incompatibility with [WSLg](https://github.com/microsoft/wslg).

WSLg creates a soft link to the Unix-domain socket `/tmp/.X11-unix` used by [Xorg](https://www.x.org/) for [local network connections](https://www.x.org/archive/X11R6.8.0/doc/Xorg.1.html#sect4). This breaks `wlroots` at <https://gitlab.freedesktop.org/wlroots/wlroots/-/blob/0.15.1/xwayland/sockets.c#L94-97>.

The script [`2-sway.sh`](./scripts/2-sway.sh) installs Sway with the required dependencies and applies a [patch](./scripts/2-wsl-wlroots.sh) to the `wlroots` library to fix that issue with WSLg. It also configures Sway to run in headless mode with a slightly modified version of the [default configuration file](https://github.com/swaywm/sway/blob/v1.7/config.in):

- Set _ALT_ as the modifier key
- Set the resolution for the _HEADLESS-1_ output to 1600x900
- Launch [wayvnc](https://github.com/any1/wayvnc)

To execute the Sway installation script, open a PowerShell session in your Windows host, go to the `scripts` folder, and execute the command:

```powershell
wsl -d ArchLinuxUnofficial -e bash -- ./2-sway.sh
```

It is possible to run Sway with WSLg (unset the `WLR_BACKENDS` environment variable if you want to try), but in my case it spawns a window without title bar and I couldn't move it.

To improve the experience, the script installs _wayvnc_ to provide VNC access to Sway. To keep the configuration required to access the VNC server simple, _wayvnc_ is configured to accept unauthenticated connections from any interface. This shouldn't be an issue because WSL2 distros by default can't be accessed from your LAN. But if you [enable access from your LAN to the VNC port of your Arch Linux distro](https://docs.microsoft.com/windows/wsl/networking#accessing-a-wsl-2-distribution-from-your-local-area-network-lan), you will need to implement some kind of [user authentication and encryption to protect your VNC session](https://github.com/any1/wayvnc#running).

The installation process creates the script `~/.local/bin/s` to launch Sway with a [D-Bus](https://www.freedesktop.org/wiki/Software/dbus/) session. Run this script and connect with a VNC client (for example, [TigerNVC](https://tigervnc.org/)) from your Windows host using the `localhost` address. Execute `winget install -e --id TigerVNCproject.TigerVNC` to install _TigerVNC Viewer_.

Audio support is provided by [PipeWire](https://pipewire.org/) and the [WSLg PulseAudio plugin](https://github.com/microsoft/wslg#pulse-audio-plugin).

## Customize the image

You can package your own custom image with the following steps. More details are available at <https://docs.microsoft.com/windows/wsl/use-custom-distro#import-the-tar-file-into-wsl>

1. Create a folder to store the distribution (for example, `C:\wslDistroStorage\ArchLinux`)
1. Download one of the images available at <https://gitlab.archlinux.org/archlinux/archlinux-docker/-/releases>. Extract the `tar` file to any folder and run the following command to import it to WSL:

    ```powershell
    wsl --import ArchLinux C:\wslDistroStorage\ArchLinux .\base-XXXXXXXX.X.XXXXX.tar
    ```

1. Use the command `wsl -d ArchLinux` to run the newly imported Arch Linux distribution.
1. Make any customization you want to your distro.
1. When you are done with the customization, logout from `WSL` and run the following commands to export the image. You can install [7-zip](https://7-zip.org/) by running `winget install -e --id 7zip.7zip`.

```powershell
wsl --terminate ArchLinux
wsl --export ArchLinux .\install.tar
& "$env:ProgramFiles\7-Zip\7z.exe" a .\install.tar.gz .\install.tar

# Optionally remove this distro
# wsl --unregister ArchLinux
```

## Setup the development environment

If you don't have Visual Studio, you can download the free Community edition with `winget`:

```powershell
winget install -e --id Microsoft.VisualStudio.2022.Community

# Run the following command with an elevated PowerShell session
# to install the required workloads to build this project
& "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe" modify `
    --productId Microsoft.VisualStudio.Product.Community `
    --channelId VisualStudio.17.Release `
    --add Microsoft.VisualStudio.Workload.NativeDesktop `
    --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
    --add Microsoft.VisualStudio.Component.Windows10SDK.19041 `
    --add Microsoft.VisualStudio.Workload.Universal `
    --passive
```

Open the main solution `DistroLauncher.sln` with Visual Studio and generate a test certificate:

1. In Visual Studio, open `DistroLauncher-Appx/MyDistro.appxmanifest`
1. Select the Packaging tab
1. Select "Choose Certificate"
1. Click the "Create" button

## Building the project

Create a sub-folder with name `x64` in the root folder of this project and copy the customized `image.tar.gz` file to it.

```powershell
PS C:\repos\WSL-DistroLauncher> tree /F
Folder PATH listing
C:.
│   .gitignore
│   build.bat
│   DistroLauncher.sln
│   LICENSE
│   README.md
│
├───DistroLauncher
|   |   ...
|
├───DistroLauncher-Appx
│   │   ...
│
├───scripts
|   |   ...
│
└───x64
    │   install.tar.gz
    │   ...
```

Use the Windows Start menu to open the "Developer Command Prompt for Visual Studio", go to the root folder of this project and run `.\build.bat rel`.

Once you've completed the build, the packaged `MSIX` should be placed in the folder `x64\Release\DistroLauncher-Appx` and should be named something like `DistroLauncher-Appx_1.1.XXXXX.0_x64.msix`.

Before using the package, you need to import the certificate used to sign it. You can extract the certificate with _Git Bash_ and [OpenSSL](https://www.openssl.org/):

```bash
openssl pkcs12 \
    -in path/to/DistroLauncher-Appx_TemporaryKey.pfx \
    -out path/to/DistroLauncher-Appx_TemporaryKey.crt \
    -nokeys
```

After extracting the certificate, you can import it to a certificate store with the same command described in the [installation section](#installation).

With the certificate installed, simply double click the `MSIX` file to start your custom distro installation process.

## Arch Linux trademark

The logos used in this launcher were taken from the [Arch Linux logos and artwork page](https://archlinux.org/art/), and I believe their usage in this project fits the [permitted use](https://wiki.archlinux.org/title/DeveloperWiki:TrademarkPolicy#Permitted_Use) condition from their trademark policy.
