#!/bin/bash
#
# Set pulseaudio server environment variable.

set -o errexit -o nounset

echo "export PULSE_SERVER=127.0.0.1" >> "${HOME}/.bashrc"
