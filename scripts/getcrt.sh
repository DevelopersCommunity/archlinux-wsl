#!/bin/bash
#
# Extract certificate from PFX

set -o errexit -o nounset

openssl pkcs12 \
  -in ../DistroLauncher-Appx/DistroLauncher-Appx_TemporaryKey.pfx \
  -out ./DistroLauncher-Appx_TemporaryKey.crt \
  -nokeys
