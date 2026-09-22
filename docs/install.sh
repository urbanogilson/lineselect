#!/bin/sh
# lineselect installer
#
# Usage:
#   curl -fsSL https://urbanogilson.github.io/lineselect/install.sh | sh
#
# Pin a specific version:
#   LINESELECT_VERSION=0.2.2 curl -fsSL https://urbanogilson.github.io/lineselect/install.sh | sh
#
# Override the install directory (default: $HOME/.local/bin):
#   LINESELECT_INSTALL_DIR=/usr/local/bin curl -fsSL https://urbanogilson.github.io/lineselect/install.sh | sh

set -eu

REPO="urbanogilson/lineselect"

say() { printf '%s\n' "$*" >&2; }
err() { printf 'error: %s\n' "$*" >&2; exit 1; }

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        err "required command '$1' not found"
    fi
}

main() {
    need_cmd curl
    need_cmd uname
    need_cmd mktemp
    need_cmd sha256sum
    need_cmd install

    os="$(uname -s)"
    case "$os" in
        Linux) ;;
        *)
            err "lineselect's install script only supports Linux (detected: $os).
Try: cargo install lineselect
Or download a release manually from https://github.com/${REPO}/releases"
            ;;
    esac

    arch="$(uname -m)"
    case "$arch" in
        x86_64|amd64) target="x86_64-unknown-linux-gnu" ;;
        aarch64|arm64) target="aarch64-unknown-linux-gnu" ;;
        *) err "unsupported architecture: $arch (lineselect only ships x86_64 and aarch64 Linux builds)" ;;
    esac

    version="${LINESELECT_VERSION:-}"
    if [ -n "$version" ]; then
        version="${version#v}"
        tag="v${version}"
    else
        tag="$(curl -fsSL -o /dev/null -w '%{url_effective}' "https://github.com/${REPO}/releases/latest" | sed 's#.*/tag/##')"
        if [ -z "$tag" ]; then
            err "could not resolve the latest release; try pinning a version with LINESELECT_VERSION"
        fi
        version="${tag#v}"
    fi

    install_dir="${LINESELECT_INSTALL_DIR:-$HOME/.local/bin}"
    asset="lineselect-${version}-${target}"
    base_url="https://github.com/${REPO}/releases/download/${tag}"

    tmpdir="$(mktemp -d)"
    trap 'rm -rf "$tmpdir"' EXIT

    say "downloading lineselect ${version} (${target})..."
    curl -fsSL -o "${tmpdir}/${asset}" "${base_url}/${asset}" \
        || err "failed to download ${base_url}/${asset}. Check that version ${version} exists and has Linux assets"
    curl -fsSL -o "${tmpdir}/${asset}.sha256" "${base_url}/${asset}.sha256" \
        || err "failed to download checksum file ${base_url}/${asset}.sha256"

    ( cd "$tmpdir" && sha256sum -c "${asset}.sha256" >/dev/null ) \
        || err "checksum verification failed for ${asset}, aborting install"

    mkdir -p "$install_dir"
    install -m 755 "${tmpdir}/${asset}" "${install_dir}/lineselect"

    say "installed lineselect ${version} to ${install_dir}/lineselect"

    check_path "$install_dir"
}

check_path() {
    install_dir="$1"
    case ":$PATH:" in
        *":$install_dir:"*) ;;
        *)
            say ""
            say "warning: ${install_dir} is not on your PATH."
            say "  add it by running one of:"
            say "    bash/zsh: echo 'export PATH=\"${install_dir}:\$PATH\"' >> ~/.bashrc   (or ~/.zshrc)"
            say "    fish:     fish_add_path ${install_dir}"
            ;;
    esac
}

main "$@"
