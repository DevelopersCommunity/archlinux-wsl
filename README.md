# WSL Arch Linux Launcher

## Introduction

This is an [Arch Linux](https://archlinux.org) installer/launcher for the [Windows Subsystem for Linux (WSL)](https://docs.microsoft.com/windows/wsl/). This installer was built using the [WSL Distro Launcher Reference Implementation](https://github.com/microsoft/WSL-DistroLauncher).

## Installation

The Arch Linux installer is packaged with the [MSIX format](https://docs.microsoft.com/windows/msix/), and it is available in the [releases page](https://github.com/DevelopersCommunity/WSL-DistroLauncher/releases) The package was signed with a self-signed certificate, you need to import it in one of your local machine certificate trusted store (for example, `Trusted People`) before using it. Execute the following PowerShell command to import it (you will need administrative privileges). The certificate is available in the [scripts](./scripts) directory. After installing the package, you can remove it from your store.

```powershell
Import-Certificate `
    -FilePath .\DistroLauncher-Appx_TemporaryKey.cer `
    -CertStoreLocation cert:\LocalMachine\TrustedPeople
```

The image installed is the Arch Linux docker base image available at the [Arch Linux docker repository](https://gitlab.archlinux.org/archlinux/archlinux-docker/-/releases) with the following changes:

- [sudo package](https://archlinux.org/packages/core/x86_64/sudo/) installed
- `wheel` group added to `sudoers`

This is the script used to build the image. It is available in the [scripts](./scripts/arch-wsl.sh) directory.

```bash
#!/bin/bash
# Prepare Arch Linux WSL image

pacman -Syu --noconfirm
pacman -Sy --noconfirm sudo

visudo=$(mktemp -q)
cat << END > "$visudo"
#!/bin/bash
# Add wheel group to sudoers.
#

echo "%wheel ALL=(ALL:ALL) ALL" > "\$2"
END

chmod +x "$visudo"
(EDITOR="$visudo" bash -c "visudo -f /etc/sudoers.d/01-wheel-group")
rm "$visudo"
```

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
│       arch-wsl.sh
│       DistroLauncher-Appx_TemporaryKey.cer
│       Export-ArchWSL.ps1
│       Import-SigningCertificate.ps1
│
└───x64
    │   install.tar.gz
    │   ...
```

Use the Windows Start menu to open the "Developer Command Prompt for Visual Studio", go to the root folder of this project and run `.\build.bat rel`.

Once you've completed the build, the packaged `MSIX` should be placed in the folder `x64\Release\DistroLauncher-Appx` and should be named something like `DistroLauncher-Appx_1.0.XXXXX.0_x64.msix`. Simply double click that `MSIX` file to open the side-loading dialog.

## Arch Linux trademark

The logos used in this launcher were taken from the [Arch Linux logos and artwork page](https://archlinux.org/art/), and I believe their usage in this project fits the permitted use clauses from their [trademark policy](https://wiki.archlinux.org/title/DeveloperWiki:TrademarkPolicy).
