#!/bin/bash
#
# Exclude Windows paths from dmenu.
# https://wiki.archlinux.org/title/Patching_packages

set -o errexit -o nounset

mkdir -p "${HOME}/patches/dmenu"
pushd .
cd "${HOME}/patches/dmenu" || exit 1

cat << END > PKGBUILD
# Maintainer: Levente Polyak <anthraxx[at]archlinux[dot]org>
# Contributor: Sergej Pupykin <pupykin.s+arch@gmail.com>
# Contributor: Bartłomiej Piotrowski <bpiotrowski@archlinux.org>
# Contributor: Thorsten Töpper <atsutane-tu@freethoughts.de>
# Contributor: Thayer Williams <thayer@archlinux.org>
# Contributor: Jeff 'codemac' Mickey <jeff@archlinux.org>

pkgname=dmenu
pkgver=5.1
pkgrel=1
pkgdesc='Generic menu for X'
url='https://tools.suckless.org/dmenu/'
arch=('x86_64')
license=('MIT')
depends=('sh' 'glibc' 'coreutils' 'libx11' 'libxinerama' 'libxft' 'freetype2' 'fontconfig' 'libfontconfig.so')
source=(https://dl.suckless.org/tools/dmenu-\${pkgver}.tar.gz nowindows.patch)
sha512sums=('2f950c30e15880e6081e04d73dd0cf8f402f52d793a77d22c3f10739bfed6222a9c4e7ec8eb3fc676422fea09e30b8cf9789f67b276b22c398c96f5ed3b56453'
            'b49166745833e7d4bebd38c5c378534a77be57024a9f1dc5a710e3b13019e6c3e45e637a2d02136733488b843bf58d14793a30fdf3c81fe53b637f597b664e68')
b2sums=('22132d851c37c6fd7b08ce1087cb33278f3194412cc590b196831568f7fc0b25e1b7a98b83720fcd5df1f8bae095ea7405b96003a698038599b1f25b58aa8a3c'
        '2d4a0e8e6a195bc1f003e593c55d5baf175e0c63498b959b017498aa5079e71ae980e83f484097b2d8c3b44431afd4b5f291a08fb18da88a2379d14d471167d1')

prepare() {
  cd \${pkgname}-\${pkgver}
  echo "CPPFLAGS+=\${CPPFLAGS}" >> config.mk
  echo "CFLAGS+=\${CFLAGS}" >> config.mk
  echo "LDFLAGS+=\${LDFLAGS}" >> config.mk
  patch --forward --strip=1 --input="\${srcdir}/nowindows.patch"
}

build() {
  cd \${pkgname}-\${pkgver}
  make \
	  X11INC=/usr/include/X11 \
	  X11LIB=/usr/lib/X11 \
	  FREETYPEINC=/usr/include/freetype2
}

package() {
  cd \${pkgname}-\${pkgver}
  make PREFIX=/usr DESTDIR="\${pkgdir}" install
  install -Dm 644 LICENSE -t "\${pkgdir}/usr/share/licenses/\${pkgname}"
}

# vim: ts=2 sw=2 et:
END

cat << END > nowindows.patch
diff --unified --recursive --text package.orig/dmenu_path package.new/dmenu_path
--- package.orig/dmenu_path	2022-03-22 22:37:07.004742900 -0300
+++ package.new/dmenu_path	2022-03-22 22:39:00.944742900 -0300
@@ -5,9 +5,12 @@
 
 [ ! -e "\$cachedir" ] && mkdir -p "\$cachedir"
 
+PATHNOWINDOWS=\$(echo "\${PATH}" \\
+	| sed 's/\\/mnt\\/[[:alpha:]]\\/[^:]*\\(:\\|\$\\)//g' | sed 's/:\$//')
+
 IFS=:
-if stest -dqr -n "\$cache" \$PATH; then
-	stest -flx \$PATH | sort -u | tee "\$cache"
+if stest -dqr -n "\$cache" \$PATHNOWINDOWS; then
+	stest -flx \$PATHNOWINDOWS | sort -u | tee "\$cache"
 else
 	cat "\$cache"
 fi
END

makepkg
sudo pacman -U --noconfirm dmenu-*-x86_64.pkg.tar.zst

popd || exit 1
