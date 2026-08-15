#!/usr/bin/env bash
#
# Download and run the architecture-aware Outline installer from this fork.
# The installer pulls the prebuilt multi-architecture image from GHCR; it does
# not require the Outline source tree or a compiler on the VPS.

set -euo pipefail

readonly INSTALL_REF="${OUTLINE_INSTALL_REF:-master}"
readonly INSTALL_URL="https://raw.githubusercontent.com/QHuy69/outline-server/${INSTALL_REF}/src/server_manager/install_scripts/install_server.sh"
readonly DEFAULT_IMAGE='ghcr.io/qhuy69/outline-server:latest'

fetch() {
  if command -v wget >/dev/null 2>&1; then
    wget --quiet --show-progress -O - "$1"
  elif command -v curl >/dev/null 2>&1; then
    curl --fail --silent --show-error --location "$1"
  else
    echo 'error: wget or curl is required' >&2
    return 1
  fi
}

installer_file="$(mktemp)"
trap 'rm -f "${installer_file}"' EXIT

fetch "${INSTALL_URL}" > "${installer_file}"
chmod 700 "${installer_file}"

# Docker selects linux/amd64 or linux/arm64 from the GHCR manifest automatically.
export SB_IMAGE="${SB_IMAGE:-${DEFAULT_IMAGE}}"
exec bash "${installer_file}" "$@"
