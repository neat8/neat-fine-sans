#!/bin/bash
set -ex
DIR="$(dirname "${BASH_SOURCE[0]}")"
BASEDIR="$DIR/.."
cd "$BASEDIR"

OUTPUT_DIR="$BASEDIR/build_output"
SOURCE_DIR="$BASEDIR/Sources"
FONTS_DIR="$BASEDIR/Fonts"

# Pin head.modified so rebuilding unchanged sources produces byte-identical
# fonts, keeping the committed binaries out of the diff. Override by exporting
# SOURCE_DATE_EPOCH before running, e.g. to stamp a release build with its date.
export SOURCE_DATE_EPOCH="${SOURCE_DATE_EPOCH:-1632128400}"  # 2021-09-20 12:00 +0300

rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/ttf" "$OUTPUT_DIR/otf" "$OUTPUT_DIR/ufo" "$OUTPUT_DIR/variable"

for src in "$SOURCE_DIR"/*.glyphs; do
  fontmake -g "$src" -i -o ttf --output-dir "$OUTPUT_DIR/ttf"
  fontmake -g "$src" -i -o otf --output-dir "$OUTPUT_DIR/otf"
  fontmake -g "$src" -i -o ufo --output-dir "$OUTPUT_DIR/ufo"
  fontmake -g "$src" -o variable --output-dir "$OUTPUT_DIR/variable"
done

# Add GASP/prep tables for these unhinted fonts. Deliberately NOT `gftools
# fix-font`: its name-table rebuild mis-splits the "Extra Bold"/"Semi Bold"
# style names into family "... Extra"/style "Bold" and resets usWeightClass.
for font in "$OUTPUT_DIR"/ttf/*.ttf "$OUTPUT_DIR"/variable/*.ttf; do
  gftools fix-nonhinting "$font" "$font"
done
rm -f "$OUTPUT_DIR"/ttf/*-backup-fonttools-prep-gasp.ttf
rm -f "$OUTPUT_DIR"/variable/*-backup-fonttools-prep-gasp.ttf

python3 "$SOURCE_DIR/postprocess.py" "$OUTPUT_DIR"

# STAT axis values for the variable fonts; both files are passed together so
# the roman/italic pair is linked via an 'ital' axis record.
gftools gen-stat "$OUTPUT_DIR"/variable/*.ttf --inplace

cp "$OUTPUT_DIR"/ttf/NeatFineSans-*.ttf "$FONTS_DIR/TrueType/"
cp "$OUTPUT_DIR"/otf/NeatFineSans-*.otf "$FONTS_DIR/OpenType/"
cp "$OUTPUT_DIR"/variable/NeatFineSans-VF.ttf "$FONTS_DIR/Variable/NeatFineSans[wght].ttf"
cp "$OUTPUT_DIR"/variable/NeatFineSans-Italic-VF.ttf "$FONTS_DIR/Variable/NeatFineSans-Italic[wght].ttf"

# Only Thin/Regular/Black (roman & italic) UFO instances are shipped.
for w in Thin Regular Black ThinItalic RegularItalic BlackItalic; do
  rm -rf "$FONTS_DIR/UFO/NeatFineSans-$w.ufo"
  cp -r "$OUTPUT_DIR/ufo/NeatFineSans-$w.ufo" "$FONTS_DIR/UFO/NeatFineSans-$w.ufo"
done

python3 "$SOURCE_DIR/build_webfonts.py"

# Quality checks run in CI (.github/workflows/build.yml); to run them locally:
#   fontbakery check-universal Fonts/TrueType/*.ttf --loglevel WARN
#   fontbakery check-universal Fonts/Variable/*.ttf --loglevel WARN
cd -
