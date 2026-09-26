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

## Using it outside of Plasma (Hyprland, Sway, ...)

### Qt applications

Select the style, with one of:

- `QT_STYLE_OVERRIDE=BreezeTransparent` in the session environment
  (Hyprland: `env = QT_STYLE_OVERRIDE,BreezeTransparent`)
- qt6ct (`QT_QPA_PLATFORMTHEME=qt6ct`): choose *BreezeTransparent* under Appearance → Style
- KDE platform theme (`QT_QPA_PLATFORMTHEME=kde`): `kwriteconfig6 --file kdeglobals --group KDE --key widgetStyle BreezeTransparent`

Change the transparency with the settings dialog:

```sh
kcmshell6 kstyle_config/breezetransparentstyleconfig
```

(also listed as *Breeze Transparent Widget Style* in application launchers), or directly in
`~/.config/breezetransparentrc`:

| Group | Key | Default | |
|---|---|---|---|
| `Common` | `WindowOpacity` | `85` | window background opacity in percent, `100` disables transparency |
| `Common` | `WindowBlurEnabled` | `true` | ask the compositor to blur behind windows (KWin only, see below) |
| `Style` | `TranslucentViews` | `true` | also make lists, file views and text editors translucent |
| `Style` | `WindowOpacityBlackList` | | comma separated application names that always stay opaque |

```sh
kwriteconfig6 --file breezetransparentrc --group Common --key WindowOpacity 70
# apply to running applications, without restarting them
dbus-send --session --type=signal /BreezeStyle org.kde.Breeze.Style.reparseConfiguration
```

The settings dialog sends that signal itself when applying changes. Enabling transparency
(going from `100` to a lower value) only takes effect in newly started applications.

Blur is requested through KDE's blur protocol, which other compositors ignore: enable blur in
the compositor instead (Hyprland: `decoration { blur { enabled = true } }`, applied to all
translucent windows). The window decoration (and its settings) is a KWin plugin, and has no
effect elsewhere.

### GTK applications

Select `Breeze-Transparent` or `Breeze-Transparent-Dark`:

```sh
gsettings set org.gnome.desktop.interface gtk-theme Breeze-Transparent-Dark
```

or `gtk-theme-name=` in `~/.config/gtk-3.0/settings.ini` and `~/.config/gtk-4.0/settings.ini`.
libadwaita applications ignore GTK themes.

The opacity is set when building the package (`_gtk_window_opacity=70 makepkg`, default 85).
To change it for your user without rebuilding:

```sh
breeze-transparent-gtk-opacity 70     # percent, then restart GTK applications
breeze-transparent-gtk-opacity show
breeze-transparent-gtk-opacity reset  # back to the built-in opacity
```

This writes `breeze-transparent.css` to `~/.config/gtk-3.0` and `~/.config/gtk-4.0`, and adds
`@import url("breeze-transparent.css");` at the top of `gtk.css` there (the rest of the file is kept,
symlinks are followed). Doing the same by hand, the file redefines the theme's translucent colors:

```css
@define-color theme_bg_color_translucent_breeze alpha(@theme_bg_color_breeze, 0.7);
@define-color theme_unfocused_bg_color_translucent_breeze alpha(@theme_unfocused_bg_color_breeze, 0.7);
@define-color theme_titlebar_background_translucent_breeze alpha(@theme_titlebar_background_breeze, 0.7);
@define-color theme_titlebar_background_backdrop_translucent_breeze alpha(@theme_titlebar_background_backdrop_breeze, 0.7);
```

## Building the package

```sh
cd pkg && makepkg -si
```
