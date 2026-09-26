# Breeze Transparent

Breeze (Qt widget style, KWin window decoration) and Breeze GTK with translucent window backgrounds,
installable next to stock Breeze.

- `breeze/`, `breeze-gtk/`: upstream sources, as git submodules pinned to the release the patches apply to
- `patches/`: the changes, one patch per submodule
- `pkg/`: Arch Linux PKGBUILD, building from the upstream release tarballs and `patches/`

## Working on the sources

```sh
scripts/setup.sh            # clone the submodules and apply the patches
# ... edit, build (cmake -B build -S breeze, ...) ...
scripts/update-patches.sh   # write the changes back to patches/, refresh the PKGBUILD checksums
```

`scripts/setup.sh --reset` discards local changes in the submodules and applies the patches again.

To move to a new upstream release, check out the new tag in each submodule, bump `pkgver`
in `pkg/PKGBUILD`, apply and fix up the patches, then run `scripts/update-patches.sh`.

## Building the package

```sh
cd pkg && makepkg -si
```
