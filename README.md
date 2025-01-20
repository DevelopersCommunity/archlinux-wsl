# Custom Arch Linux distribution for WSL

This is an automated script to create an [Arch Linux](https://archlinux.org)
[WSL](https://aka.ms/wsl/) [modern
distribution](https://learn.microsoft.com/windows/wsl/build-custom-distro).

You can download a pre-built version from the [releases
page](https://github.com/DevelopersCommunity/archlinux-wsl/releases/latest).
Get the `archlinux.wsl` file and double-click it in `File Explorer` to
install the distribution.

## Requirements

You need [WSL release 2.4.4 or higher](https://github.com/microsoft/WSL/releases)
to use this installation method. To install a pre-release version of WSL, run
the following command:

```powershell
wsl --update --pre-release
```

To build the distribution, you need the following tools:

- [Docker Engine](https://docs.docker.com/engine/). On Windows, you can build
the distribution using [WSL with Docker
support](https://docs.docker.com/desktop/features/wsl/).
- [Docker Buildx](https://docs.docker.com/build/concepts/overview/)
- [Docker personal access
token](https://docs.docker.com/security/for-developers/access-tokens/)
- [curl](https://curl.se/)
- [Node.js](https://nodejs.org/)
- [jq](https://jqlang.github.io/jq/)
- [grep](https://www.gnu.org/software/grep/)

## Build

Before building, create a `.env` file with your Docker credentials:

```env
DOCKER_HUB_USERNAME=<your docker user name>
DOCKER_HUB_PAT=<your docker account personal access token>
```

Then run the [`build`](./build) script to create the `archlinux.wsl` file.

## Windows Terminal profile

The build process creates a custom profile for the [Windows
Terminal](https://learn.microsoft.com/windows/terminal/). The color scheme is a
[Material Design dynamically generated color
scheme](https://m3.material.io/styles/color/dynamic/choosing-a-source) based on
the [Arch Linux logo](https://archlinux.org/art/) blue color. The script to
generate the profile is available in the [`terminal-profile`
directory](./terminal-profile/).

## Known issues

### systemd services won't start

If you get the following error when running the `systemctl` command, try to
[install another WSL distribution with `systemd`
support](https://aka.ms/wslsystemd/) and check if it works. In my case,
`systemd` started working on Arch Linux after that, and kept working even after
uninstalling the other distro.

```terminal
$ systemctl
Failed to connect to system scope bus via local transport: No such file or directory
```

If you still have problems after installing another distribution, try to run the
following
[command](https://github.com/microsoft/WSL/issues/10205#issuecomment-1601620093)
in a `PowerShell` terminal:

```powershell
wsl -d Arch-Linux-Unofficial -u root -e systemctl restart user@1000.service
```

## Arch Linux trademark
 
The logo used in this distribution was taken from the [Arch Linux logos and
artwork page](https://archlinux.org/art/), and I believe its usage in this
project fits the [permitted
use](https://wiki.archlinux.org/title/DeveloperWiki:TrademarkPolicy#Permitted_Use)
condition from their trademark policy.

<!-- vim: set spell spelllang=en: -->
