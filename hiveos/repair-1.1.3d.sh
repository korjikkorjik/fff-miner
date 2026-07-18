#!/usr/bin/env bash
set -euo pipefail

CUSTOM_ROOT=/hive/miners/custom
HIVE_COMMIT=72cae73d1f2788b999df30773091cad72e068de7
HIVE_BASE="https://raw.githubusercontent.com/minershive/hiveos-linux/${HIVE_COMMIT}/hive/miners/custom"
FFF_URL="https://github.com/korjikkorjik/fff-miner/releases/download/v1.1.3f/fff-1.1.3f.tar.gz"

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
  echo "Run this repair as root." >&2
  exit 1
fi

if [[ ! -x "$CUSTOM_ROOT/custom-get" ]]; then
  echo "$CUSTOM_ROOT/custom-get is missing; update/reinstall HiveOS first." >&2
  exit 1
fi

command -v miner >/dev/null 2>&1 && miner stop || true
pkill -f '/hive/miners/custom/fff/fff.bin' 2>/dev/null || true
pkill -f '/hive/miners/custom/fff.bin' 2>/dev/null || true
pkill -f '/hive/miners/custom/h-run.sh' 2>/dev/null || true

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for file in h-config.sh h-run.sh h-stats.sh h-manifest.conf; do
  wget -qO "$tmp_dir/$file" "$HIVE_BASE/$file"
  test -s "$tmp_dir/$file"
done

install -o root -g root -m 755 "$tmp_dir/h-config.sh" "$CUSTOM_ROOT/h-config.sh"
install -o root -g root -m 755 "$tmp_dir/h-run.sh" "$CUSTOM_ROOT/h-run.sh"
install -o root -g root -m 755 "$tmp_dir/h-stats.sh" "$CUSTOM_ROOT/h-stats.sh"
install -o root -g root -m 644 "$tmp_dir/h-manifest.conf" "$CUSTOM_ROOT/h-manifest.conf"

rm -f \
  "$CUSTOM_ROOT/fff.bin" \
  "$CUSTOM_ROOT/fff.conf" \
  "$CUSTOM_ROOT/fff.log" \
  "$CUSTOM_ROOT/fff-pids" \
  "$CUSTOM_ROOT/README-hiveos.txt"

"$CUSTOM_ROOT/custom-get" "$FFF_URL" -f

test -x "$CUSTOM_ROOT/fff/fff.bin"
test -x "$CUSTOM_ROOT/fff/h-run.sh"
grep -q 'FFF_BIN=./fff.bin' "$CUSTOM_ROOT/fff/h-run.sh"

echo "HiveOS custom-miner wrappers restored."
echo "FFF 1.1.3f installed in $CUSTOM_ROOT/fff."
echo "Re-apply the required flight sheet now."
