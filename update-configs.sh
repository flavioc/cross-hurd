CONFIG_GUESS_URL="https://git.savannah.gnu.org/cgit/config.git/plain/config.guess"
CONFIG_SUB_URL="https://git.savannah.gnu.org/cgit/config.git/plain/config.sub"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

wget -O "$TMPDIR/config.guess" "$CONFIG_GUESS_URL"
wget -O "$TMPDIR/config.sub" "$CONFIG_SUB_URL"

if [ ! -s "$TMPDIR/config.guess" ] || [ ! -s "$TMPDIR/config.sub" ]; then
  echo "Error: Failed to download config.guess or config.sub"
  exit 1
fi

update_configs_in_dir() {
  local dir="$1"
  if [ -d "$dir" ]; then
    find "$dir" -type f \( -name "config.guess" -o -name "config.sub" \) | while read -r f; do
      base=$(basename "$f")
      cp -f "$TMPDIR/$base" "$f"
      chmod +x "$f"
    done
  fi
}
