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
    # Some VPS networks advertise IPv6 but do not route it correctly. Use
    # IPv4 and a finite timeout so a failed GitHub connection is actionable.
    wget --inet4-only --timeout=20 --tries=3 --show-progress -O - "$1"
  elif command -v curl >/dev/null 2>&1; then
    curl --ipv4 --fail --silent --show-error --location \
      --connect-timeout 20 --max-time 60 "$1"
  else
    echo 'error: wget or curl is required' >&2
    return 1
  fi
}

has_hostname_arg() {
  for arg in "$@"; do
    case "${arg}" in
      --hostname|--hostname=*) return 0 ;;
    esac
  done
  return 1
}

# Make the common case fully automatic. The upstream installer requires a
# public hostname for access URLs, so discover the VPS public IPv4 when the
# caller did not provide one explicitly.
if ! has_hostname_arg "$@"; then
  public_ip=''
  if public_ip="$(fetch 'https://api.ipify.org' 2>/dev/null | tr -d '[:space:]')" \
    && [[ "${public_ip}" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
    set -- --hostname "${public_ip}" "$@"
  else
    echo 'error: could not detect the VPS public IPv4; rerun with --hostname YOUR_PUBLIC_IP' >&2
    exit 1
  fi
fi

installer_file="$(mktemp)"
trap 'rm -f "${installer_file}"' EXIT

fetch "${INSTALL_URL}" > "${installer_file}"
chmod 700 "${installer_file}"

# Docker selects linux/amd64 or linux/arm64 from the GHCR manifest automatically.
export SB_IMAGE="${SB_IMAGE:-${DEFAULT_IMAGE}}"
exec bash "${installer_file}" "$@"
