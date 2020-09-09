#!/bin/bash

set -u
set -e

echo "ACN 5202 Post-build: processing $@"

BOARD_DIR="$(dirname $0)"

# Create links for PlayReady
mkdir -p "${TARGET_DIR}/etc/playready/"
mkdir -p "${TARGET_DIR}/root/OCDM/"
ln -sf /tmp/drmstore "${TARGET_DIR}/etc/playready/storage"
ln -sf /etc/playready "${TARGET_DIR}/root/OCDM/playready"
