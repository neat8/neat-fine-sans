# Neat Fine Sans

A modern, geometric typeface. Influenced by other popular geometric, minimalist sans-serif typefaces of the new millenium. Designed for optimal readability at small point sizes while beautiful at large point sizes.

Ships as static weights (Thin–Black, roman & italic) and as variable fonts with a `wght` axis spanning 100–900.

### Stylistic set: single-storey `a`

A single-storey (geometric) alternate for `a` and its accented forms is available as `ss01`, or via the stylistic alternates palette (`salt`) in design applications:

```css
.geometric-a {
  font-family: 'Neat Fine Sans';
  font-feature-settings: 'ss01';
}
```

---

Build instructions
------------------

```
python3 -m venv venv
. venv/bin/activate  # Unixoids...
venv/Scripts/activate  # ...or on Windows cmd.exe or PowerShell

pip3 install -r Sources/requirements.txt

./Sources/build.sh
```

### Where am I?

See [Documentation](./docs/Documentation.md).

## License

Licensed under Open Font License (OFL). See [LICENSE](./LICENSE).

### Attribution

Neat Fine Sans is based upon the work done by @chrismsimpson on Metropolis. The upstream Metropolis repository has since been deleted/made private by its author; this project continues as an independent fork under a new name.
