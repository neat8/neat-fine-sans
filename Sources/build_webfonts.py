#!/usr/bin/env python3
"""Generate WOFF/WOFF2 webfonts from the built TrueType and variable fonts."""
import glob
import os

from fontTools.ttLib import TTFont

BASEDIR = os.path.join(os.path.dirname(__file__), "..")
TTF_DIR = os.path.join(BASEDIR, "Fonts", "TrueType")
VARIABLE_DIR = os.path.join(BASEDIR, "Fonts", "Variable")
WOFF_DIR = os.path.join(BASEDIR, "Fonts", "Webfonts", "WOFF")
WOFF2_DIR = os.path.join(BASEDIR, "Fonts", "Webfonts", "WOFF2")

os.makedirs(WOFF_DIR, exist_ok=True)
os.makedirs(WOFF2_DIR, exist_ok=True)

for ttf_path in sorted(glob.glob(os.path.join(TTF_DIR, "NeatFineSans-*.ttf"))):
    base = os.path.splitext(os.path.basename(ttf_path))[0]
    for flavor, out_dir in [("woff", WOFF_DIR), ("woff2", WOFF2_DIR)]:
        font = TTFont(ttf_path)
        font.flavor = flavor
        font.save(os.path.join(out_dir, f"{base}.{flavor}"))

for vf_name in ["NeatFineSans[wght]", "NeatFineSans-Italic[wght]"]:
    ttf_path = os.path.join(VARIABLE_DIR, f"{vf_name}.ttf")
    font = TTFont(ttf_path)
    font.flavor = "woff2"
    font.save(os.path.join(VARIABLE_DIR, f"{vf_name}.woff2"))

print("Webfonts generated.")
