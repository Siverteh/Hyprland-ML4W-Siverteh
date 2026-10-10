# Dolphin Files and live Nacre colors

Dolphin is Nacre's selected file manager. Super+Shift+F, the Files app route,
folder associations and ZIP associations use its Nacre launcher. Super+F remains
the fullscreen shortcut. Personal explicit routes in `~/.config/nacre/apps.json`
are supported.

Double-click ZIP archives to browse their contents like a folder. This is native
Dolphin/KIO archive navigation; it does not extract every file into the parent
folder. Copy items out when needed. The native setting is
`General/BrowseThroughArchives` in dolphinrc.

The default layout uses a centered floating window at 80% screen width and 75%
height, 80px file icons, 96px previews,
22px Places icons and the shared Noto Sans font. Breadcrumb navigation, a quiet
menu toolbar and Nacre's dark/light surfaces, text, accents and Papirus folder
colors follow the existing palette publisher. First-run setup backs up preferences
and associations; later layout edits are not overwritten. Ctrl+L edits the path,
Ctrl+M shows the menu and F3 toggles split view.

`dolphin-files.py` removes old native-library/QML overrides and selects the scoped
NacreDolphin style. The compiled style-only adapter uses public Qt/KDE interfaces
and native Breeze. It watches generated `Nacre.colors` and kdeglobals, refreshes
KDE's shared scheme cache and Dolphin's item-style caches, and recolors open windows
without restarting them or interrupting transfers. Other applications do not
activate its palette watcher. No second palette engine or polling timer is added.
Native Qt, KDE, Dolphin, thumbnailers and Papirus remain pacman-managed.

Install native packages, then deploy through the normal plan/apply workflow:

```sh
sudo pacman -S --needed dolphin kdegraphics-thumbnailers ffmpegthumbs archlinux-xdg-menu
./install.sh --component configs --component shell
./install.sh --apply --component configs --component shell
```

The shell installer builds only the small local style adapter, seeds archive/layout
preferences once and prepares KDE application-menu metadata. Its folder activation
service starts Dolphin on demand. Already-running older file-manager services can
retain their bus ownership until closed; migration never kills active transfers.

Tests verify native palette replacement and app isolation, literal file routes,
backup/default handling and later-edit preservation. Actual isolated previews
validate palette colors and ZIP navigation. Source/license credits for native
Breeze/Papirus remain with their distribution packages; no upstream implementation
source is copied into the adapter.

The previous Thunar command and its installed libraries may remain as a rollback
fallback. It no longer owns normal Files routes or gets rebuilt on routine shell
deployment. Personal preferences and old release backups are preserved.
