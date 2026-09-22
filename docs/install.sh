#!/bin/sh
# lineselect installer
#
# Usage:
#   curl -fsSL https://urbanogilson.github.io/lineselect/install.sh | sh
#
# Pin a specific version:
#   LINESELECT_VERSION=0.2.3 curl -fsSL https://urbanogilson.github.io/lineselect/install.sh | sh
#
# Override the install directory (default: $HOME/.local/bin):
#   LINESELECT_INSTALL_DIR=/usr/local/bin curl -fsSL https://urbanogilson.github.io/lineselect/install.sh | sh
#
# Override the build target (e.g. the static musl build on a glibc system):
#   LINESELECT_TARGET=x86_64-unknown-linux-musl curl -fsSL https://urbanogilson.github.io/lineselect/install.sh | sh

set -eu

REPO="urbanogilson/lineselect"

say() { printf '%s\n' "$*" >&2; }
err() { printf 'error: %s\n' "$*" >&2; exit 1; }

need_cmd() {
    if ! command -v "$1" >/dev/null 2>&1; then
        err "required command '$1' not found"
    fi
}

is_musl() {
    for f in /lib/ld-musl-*; do
        [ -e "$f" ] && return 0
    done
    ldd --version 2>&1 | grep -qi musl
}

detect_target() {
    os="$(uname -s)"
    arch="$(uname -m)"

    case "$arch" in
        x86_64|amd64) arch="x86_64" ;;
        aarch64|arm64) arch="aarch64" ;;
        *) err "unsupported architecture: $arch (lineselect only ships x86_64 and aarch64 builds)" ;;
    esac

    case "$os" in
        Linux)
            if is_musl; then
                echo "${arch}-unknown-linux-musl"
            else
                echo "${arch}-unknown-linux-gnu"
            fi
            ;;
        Darwin) echo "${arch}-apple-darwin" ;;
        *)
            err "lineselect's install script only supports Linux and macOS (detected: $os).
Try: cargo install lineselect
Or download a release manually from https://github.com/${REPO}/releases"
            ;;
    esac
}

sha256_check() {
    if command -v sha256sum >/dev/null 2>&1; then
        sha256sum -c "$1"
    elif command -v shasum >/dev/null 2>&1; then
        shasum -a 256 -c "$1"
    else
        err "required command 'sha256sum' or 'shasum' not found"
    fi
}

main() {
    need_cmd curl
    need_cmd uname
    need_cmd mktemp
    need_cmd install

    target="${LINESELECT_TARGET:-}"
    if [ -z "$target" ]; then
        target="$(detect_target)"
    fi

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
        || err "failed to download ${base_url}/${asset}. Check that version ${version} exists and has a build for ${target}"
    curl -fsSL -o "${tmpdir}/${asset}.sha256" "${base_url}/${asset}.sha256" \
        || err "failed to download checksum file ${base_url}/${asset}.sha256"

    ( cd "$tmpdir" && sha256_check "${asset}.sha256" >/dev/null ) \
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
