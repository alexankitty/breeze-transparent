#!/bin/sh
# Clone the pinned upstream breeze / breeze-gtk submodules and apply the
# Breeze Transparent patches on top of them.
#
# Safe to run again: submodules that already have the patches applied are left alone.
set -eu

usage() {
    cat <<EOF
Usage: $0 [--reset]

  --reset   discard local changes in the submodules (build directories are kept)
            and apply the patches again from scratch
EOF
}

reset=0
case "${1:-}" in
    '') ;;
    --reset) reset=1 ;;
    -h|--help) usage; exit 0 ;;
    *) usage >&2; exit 1 ;;
esac

root=$(cd "$(dirname "$0")/.." && pwd)
cd "$root"
. "$root/scripts/common.sh"

git submodule sync --quiet
if [ "$reset" = 1 ]; then
    update_flags="--init --force"
else
    update_flags="--init"
fi
# fetch only the pinned commit when possible, fall back to a full clone
# shellcheck disable=SC2086
if ! git submodule update $update_flags --depth 1 2>/dev/null; then
    git submodule update $update_flags
fi

for entry in $SUBMODULE_PATCHES; do
    submodule=${entry%%:*}
    patch="$root/patches/${entry#*:}"

    exclude_build_dir "$submodule"

    if [ "$reset" = 1 ]; then
        git -C "$submodule" reset --quiet --hard
        git -C "$submodule" clean --quiet -fd
    fi

    if git -C "$submodule" apply --index --check --reverse "$patch" 2>/dev/null; then
        echo "$submodule: patches already applied"
        continue
    fi

    if ! git -C "$submodule" apply --index --check "$patch"; then
        echo "$submodule: local changes conflict with ${patch#"$root"/}; run '$0 --reset' to start over" >&2
        exit 1
    fi

    git -C "$submodule" apply --index "$patch"
    echo "$submodule: applied ${patch#"$root"/}"
done
