#!/bin/sh
set -eu
case "$(uname -s)" in Linux) os=linux ;; Darwin) os=macos ;; *) echo 'Use install.ps1 on Windows.' >&2; exit 1 ;; esac
case "$(uname -m)" in x86_64|amd64) arch=x64 ;; arm64|aarch64) arch=arm64 ;; *) echo 'Unsupported processor.' >&2; exit 1 ;; esac
version=${COLLA_VERSION:-latest}
case "$version" in latest) base=https://github.com/bitfent/colla-downloads/releases/latest/download ;; v[0-9]*) base="https://github.com/bitfent/colla-downloads/releases/download/$version" ;; *) echo 'Invalid COLLA_VERSION.' >&2; exit 1 ;; esac
asset="colla-$os-$arch.tar.gz"
stage=$(mktemp -d)
trap 'rm -rf "$stage"' EXIT HUP INT TERM
curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 "$base/$asset" -o "$stage/$asset"
curl --fail --silent --show-error --location --proto '=https' --tlsv1.2 "$base/$asset.sha256" -o "$stage/checksum"
expected=$(awk '{print $1}' "$stage/checksum")
if command -v sha256sum >/dev/null 2>&1; then actual=$(sha256sum "$stage/$asset" | awk '{print $1}'); else actual=$(shasum -a 256 "$stage/$asset" | awk '{print $1}'); fi
[ "$expected" = "$actual" ] || { echo 'Checksum mismatch; nothing installed.' >&2; exit 1; }
tar -xzf "$stage/$asset" -C "$stage" colla
destination=${COLLA_BIN_DIR:-"$HOME/.local/bin"}
mkdir -p "$destination"
install -m 755 "$stage/colla" "$destination/colla.new"
mv -f "$destination/colla.new" "$destination/colla"
"$destination/colla" --version
printf 'Installed at %s/colla\n' "$destination"
case ":$PATH:" in *":$destination:"*) ;; *) printf 'Add %s to your PATH, or use the full path above.\n' "$destination" ;; esac
