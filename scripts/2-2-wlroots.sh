#!/bin/bash
#
# Workaround to make wlroots work with WSL2.

set -o errexit -o nounset -o pipefail

sudo pacman -S --needed --noconfirm base-devel
sudo pacman -S --noconfirm git cmake wayland-protocols ffmpeg vulkan-headers \
  glslang meson

wlrootspatch=$(mktemp -q)
cat << END > "${wlrootspatch}"
diff --git a/examples/meson.build b/examples/meson.build
index 26d103bb..690ba207 100644
--- a/examples/meson.build
+++ b/examples/meson.build
@@ -123,17 +123,6 @@ clients = {
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
diff --git a/xwayland/sockets.c b/xwayland/sockets.c
index 873fde8d..f4aeabb1 100644
--- a/xwayland/sockets.c
+++ b/xwayland/sockets.c
@@ -91,6 +91,9 @@ static bool check_socket_dir(void) {
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

mkdir -p "${HOME}/repos"
pushd .
cd "${HOME}/repos" || exit 1
git clone https://gitlab.freedesktop.org/wlroots/wlroots.git
cd wlroots || exit 1
git checkout 0.15.1
git apply "${wlrootspatch}"
rm "${wlrootspatch}"
meson build/
ninja -C build/
sudo ninja -C build/ install
cd /usr/lib || exit 1
sudo rm libwlroots.so.10
sudo ln -s ../local/lib/libwlroots.so.10 libwlroots.so.10
popd || exit 1

sudo dbus-uuidgen --ensure