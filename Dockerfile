FROM archlinux:base

# Apply configuration files recommendations
# https://learn.microsoft.com/windows/wsl/build-custom-distro#configuration-file-recommendations
COPY --chown=root:root --chmod=0644 root/etc/wsl.conf root/etc/wsl-distribution.conf /etc/
COPY --chown=root:root --chmod=0755 root/etc/oobe.sh /etc/

COPY root/usr/lib/wsl/* /usr/lib/wsl/

COPY --chmod=0755 configure.sh ./configure.sh
RUN ./configure.sh && rm ./configure.sh
