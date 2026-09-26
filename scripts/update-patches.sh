#!/bin/sh
# Regenerate patches/ from the changes made in the breeze / breeze-gtk submodules
# (relative to their pinned upstream commits), then refresh the PKGBUILD checksums.
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
. "$root/scripts/common.sh"

for entry in $SUBMODULE_PATCHES; do
    submodule=${entry%%:*}
    patch="$root/patches/${entry#*:}"

    exclude_build_dir "$submodule"

    # stage everything, so that new and renamed files are part of the patch
    git -C "$submodule" add --all
    git -C "$submodule" diff --cached --find-renames --no-color --no-ext-diff \
        --src-prefix=a/ --dst-prefix=b/ HEAD > "$patch"
    echo "wrote ${patch#"$root"/}"
done

if command -v updpkgsums >/dev/null 2>&1; then
    (cd pkg && updpkgsums && makepkg --printsrcinfo > .SRCINFO)
else
    echo "updpkgsums not found (pacman-contrib): update the checksums in pkg/PKGBUILD manually" >&2
fi
