# Shared by setup.sh and update-patches.sh

# submodule:patch pairs
SUBMODULE_PATCHES="breeze:breeze-transparent.patch breeze-gtk:breeze-gtk-transparent.patch"

# keep in-tree build directories out of the submodule status and the patches
exclude_build_dir() {
    exclude=$(git -C "$1" rev-parse --git-path info/exclude)
    case "$exclude" in
        /*) ;;
        *) exclude="$1/$exclude" ;;
    esac
    mkdir -p "$(dirname "$exclude")"
    grep -qx '/build/' "$exclude" 2>/dev/null || echo '/build/' >> "$exclude"
}
