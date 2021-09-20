#!/usr/bin/env python3
"""Post-process built fonts: set OFL-appropriate embedding bits and drop dead axes.

Run against build_output before the fonts are copied into Fonts/.
"""
import glob
import os
import sys

from fontTools import subset
from fontTools.ttLib import TTFont
from fontTools.varLib import instancer

BUILD_DIR = sys.argv[1] if len(sys.argv) > 1 else "build_output"


def set_installable_embedding(path):
    font = TTFont(path)
    if font["OS/2"].fsType != 0:
        font["OS/2"].fsType = 0
        font.save(path)


def drop_dead_axes(path):
    """Remove axes whose min == max: they carry no variation and confuse font UIs."""
    font = TTFont(path)
    dead = {a.axisTag: a.defaultValue for a in font["fvar"].axes if a.minValue == a.maxValue}
    if not dead:
        return
    instancer.instantiateVariableFont(font, dead, inplace=True, updateFontNames=False)
    font.save(path)
    print(f"  {os.path.basename(path)}: dropped dead axes {sorted(dead)}")


def strip_bracket_leftovers(path):
    """Static instances bake the bracket alternate into the base glyph, leaving the
    generated .BRACKET glyphs unreachable. They are still needed in the variable
    fonts, where rvrn substitutes them."""
    font = TTFont(path)
    dead = [g for g in font.getGlyphOrder() if ".BRACKET." in g]
    if not dead:
        return
    keep = [g for g in font.getGlyphOrder() if g not in dead]
    options = subset.Options()
    options.layout_features = ["*"]
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.notdef_outline = True
    options.glyph_names = True
    options.hinting = True
    options.legacy_kern = True
    subsetter = subset.Subsetter(options=options)
    subsetter.populate(glyphs=keep)
    subsetter.subset(font)
    font.save(path)
    print(f"  {os.path.basename(path)}: stripped unreachable {dead}")


for pattern in ("ttf/*.ttf", "otf/*.otf"):
    for path in sorted(glob.glob(os.path.join(BUILD_DIR, pattern))):
        strip_bracket_leftovers(path)
        set_installable_embedding(path)

for path in sorted(glob.glob(os.path.join(BUILD_DIR, "variable/*.ttf"))):
    drop_dead_axes(path)
    set_installable_embedding(path)

print("Post-processing complete.")
