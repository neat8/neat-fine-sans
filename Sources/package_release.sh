#!/bin/bash
# Package the built fonts into per-format release archives.
# Usage: ./Sources/package_release.sh [version]   (default: version from package.json)
set -eu

DIR="$(dirname "${BASH_SOURCE[0]}")"
BASEDIR="$(cd "$DIR/.." && pwd)"
cd "$BASEDIR"

VERSION="${1:-$(sed -n 's/.*"version": *"\([^"]*\)".*/\1/p' package.json)}"
DIST="$BASEDIR/dist"
PREFIX="NeatFineSans-$VERSION"

rm -rf "$DIST"
mkdir -p "$DIST"

# Each archive ships LICENSE alongside the fonts: the OFL requires the licence
# and copyright notice to accompany every copy of the font software.
package() {
  local suffix="$1"; shift
  local name="$PREFIX-$suffix"
  local staging
  staging="$(mktemp -d)"
  mkdir -p "$staging/$name"
  cp -r "$@" "$staging/$name/"
  cp LICENSE README.md "$staging/$name/"
  (cd "$staging" && zip -qr "$DIST/$name.zip" "$name")
  rm -rf "$staging"
  echo "  $(cd "$DIST" && du -h "$name.zip" | cut -f1)	$name.zip"
}

echo "Packaging $PREFIX:"
package OpenType  Fonts/OpenType/.
package TrueType  Fonts/TrueType/.
package Variable  Fonts/Variable/.
package Webfonts  Fonts/Webfonts/.
package UFO       Fonts/UFO/.
package Complete  Fonts/.

echo "Archives written to $DIST"
