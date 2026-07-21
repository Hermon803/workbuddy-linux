#!/bin/bash
# Shared shell helpers. Sourced by scripts; do not run directly.

info() {
    echo "[INFO] $*" >&2
}

warn() {
    echo "[WARN] $*" >&2
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

require_cmd() {
    command -v "$1" >/dev/null 2>&1 || error "Missing required command: $1"
}

find_7z() {
    local common_dir repo_dir bundled_7zz
    common_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    repo_dir="$(cd "$common_dir/../.." && pwd)"
    bundled_7zz="$repo_dir/.tools/7zip/7zz"

    if [ -x "$bundled_7zz" ]; then
        echo "$bundled_7zz"
        return 0
    fi

    if command -v 7zz >/dev/null 2>&1; then
        command -v 7zz
        return 0
    fi
    if command -v 7z >/dev/null 2>&1; then
        local version_output major_version
        version_output="$(7z -version 2>&1 || true)"
        if [[ "$version_output" =~ 7-Zip\ (\[[0-9]+\]\ )?([0-9]+)\. ]]; then
            major_version="${BASH_REMATCH[2]}"
            if [ "$major_version" -lt 22 ]; then
                error "Found legacy p7zip (version $major_version), which cannot extract modern DMG files properly.
APFS-based DMGs require 7-Zip 22 or newer. Run 'make deps' to install a
project-local compatible version, or install a newer system package:
  Debian/Ubuntu: sudo apt install 7zip (remove p7zip-full first)
  Fedora/RHEL:   sudo dnf install 7zip
  Arch Linux:    sudo pacman -S 7zip
  openSUSE:      sudo zypper install 7zip"
            fi
        fi
        command -v 7z
        return 0
    fi
    error "Missing 7z/7zz. Run 'make deps' or install 7-Zip 22+."
}
