#!/bin/bash
#
# Workaround to make wlroots work with WSLg.
# https://archlinux.org/packages/community/x86_64/wlroots/
# https://wiki.archlinux.org/title/Patching_packages

set -o errexit -o nounset

sudo pacman -S --needed --noconfirm cmake wayland-protocols ffmpeg meson \
  vulkan-headers glslang

mkdir -p "${HOME}/patches/wlroots"
pushd .
cd "${HOME}/patches/wlroots" || exit 1

cat << END > PKGBUILD
# Maintainer: Brett Cornwall <ainola@archlinux.org>
# Maintainer: Maxim Baz <\$pkgname at maximbaz dot com>
# Contributor: Omar Pakker

pkgname=wlroots
pkgver=0.15.1
pkgrel=3
license=('MIT')
pkgdesc='Modular Wayland compositor library'
url='https://gitlab.freedesktop.org/wlroots/wlroots'
arch=('x86_64')
depends=(
    'libglvnd'
    'libinput'
    'seatd' 'libseat.so'
    'libxcb'
    'libxkbcommon' 'libxkbcommon.so'
    'opengl-driver'
    'pixman' 'libpixman-1.so'
    'systemd-libs' 'libudev.so'
    'vulkan-icd-loader' 'libvulkan.so'
    'wayland'
    'xcb-util-errors'
    'xcb-util-renderutil'
    'xcb-util-wm'
)
makedepends=(
    'glslang'
    'meson'
    'ninja'
    'systemd'
    'vulkan-headers'
    'wayland-protocols'
    'xorg-xwayland'
)
optdepends=(
    'xorg-xwayland: Xwayland support'
)
provides=(
    'libwlroots.so'
)
options=(
    'debug'
)
source=(
    "\$pkgname-\$pkgver.tar.gz::https://gitlab.freedesktop.org/wlroots/wlroots/-/releases/\$pkgver/downloads/wlroots-\$pkgver.tar.gz"
    "https://gitlab.freedesktop.org/wlroots/wlroots/-/releases/\$pkgver/downloads/wlroots-\$pkgver.tar.gz.sig"
    'wslg.patch'
)
sha256sums=('5b92f11a52d978919ed1306e0d54c9d59f1762b28d44f0a2da3ef3b351305373'
            'SKIP'
            '5d3bf97b66c55b7ae2bee6a241534e760e20fa334a447eb0bf5c49c790608fab')
validpgpkeys=(
    '34FF9526CFEF0E97A340E2E40FDE7BE0E88F5E48' # Simon Ser
    '9DDA3B9FA5D58DD5392C78E652CB6609B22DA89A' # Drew DeVault
    '4100929B33EEB0FD1DB852797BC79407090047CA' # Sway signing key
)

build() {
    arch-meson "\$pkgname-\$pkgver" build
    ninja -C build
}

package() {
    DESTDIR="\$pkgdir" ninja -C build install
    install -Dm644 "\$pkgname-\$pkgver/LICENSE" -t "\$pkgdir/usr/share/licenses/\$pkgname/"
}

prepare() {
  patch --directory="\$pkgname-\$pkgver" --forward --strip=1 --input="\${srcdir}/wslg.patch"
}
END

cat << END > wslg.patch
diff --unified --recursive --text package.orig/examples/meson.build package.new/examples/meson.build
--- package.orig/examples/meson.build	2022-03-14 14:17:31.001658400 -0300
+++ package.new/examples/meson.build	2022-03-14 14:14:52.541658400 -0300
@@ -123,17 +123,6 @@
 			'xdg-shell',
 		],
 	},
-	'dmabuf-capture': {
-		'src': 'dmabuf-capture.c',
-		'dep': [
-			libavcodec,
-			libavformat,
-			libavutil,
-			drm,
-			threads,
-		],
-		'proto': ['wlr-export-dmabuf-unstable-v1'],
-	},
 	'screencopy': {
 		'src': 'screencopy.c',
 		'dep': [libpng, rt],
diff --unified --recursive --text package.orig/xwayland/sockets.c package.new/xwayland/sockets.c
--- package.orig/xwayland/sockets.c	2022-03-14 14:17:31.011658400 -0300
+++ package.new/xwayland/sockets.c	2022-03-14 14:05:13.151658400 -0300
@@ -91,6 +91,9 @@
 		wlr_log_errno(WLR_ERROR, "Failed to stat %s", socket_dir);
 		return false;
 	}
+	if (buf.st_mode & S_IFLNK) {
+		return true;
+	}
 	if (!(buf.st_mode & S_IFDIR)) {
 		wlr_log(WLR_ERROR, "%s is not a directory", socket_dir);
 		return false;
END

gpg --recv-keys 0FDE7BE0E88F5E48
makepkg
sudo pacman -U --noconfirm wlroots-[[:digit:]]*-x86_64.pkg.tar.zst

popd || exit 1
