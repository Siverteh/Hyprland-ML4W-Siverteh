# Launcher

[System overview](../overview.md) · [Deployment and recovery](../maintenance.md)

## Categorized bottom launcher

Super+A toggles Apps. Super by itself has no launcher binding, avoiding
accidental opens. Super+W opens Wallpaper directly. The bottom drawer has no
hover trigger.

The app browser always opens a compact Favorites view, including when empty.
All apps expands upward to six full rows when the screen has room;
other categories expand to the standard browsing height; the bottom search field
stays anchored. Typing also expands the results view. Categories come from desktop-entry metadata and empty categories are
omitted. Typing searches all visible apps; `>` searches built-in actions.
The heart toggles a favorite; right-click offers favorite/hide, and the hidden
apps button restores hidden entries. Ctrl+D toggles the selected app's favorite.
Tab moves into the category rail, arrows navigate and Enter launches; Escape
closes. Clicking outside dismisses the panel without activating the app behind
it. Power actions stay in the existing power menu.

Preferences are private atomic JSON in `~/.config/nacre/launcher.json`,
with mode 0600 and locked read/modify/write operations. They are outside source
and desktop rollback, and malformed data is preserved rather than overwritten.
The browser loads only while open/closing and uses the shared fast scrolling.


## Independent mode assembly

NacreLauncherPanel owns mode selection and lazy loading. It keeps loaded content
at a fixed internal height while the visible panel closes, clips that content,
and unloads it once the close transition settles. Reopening during a close targets
the latest state. Full-screen wallpaper modes use the existing viewport/backdrop
contract; gallery index/count/step and output recovery remain compatible.

The inherited reference-era content/list/action/item stack is removed. Its
compatibility `legacy` mode now uses the independently authored NacreSearchPanel:
app search or `>` known desktop actions, keyboard selection/Enter/Escape and
readable palette-aware rows. It does not execute arbitrary command text or add
power controls. The category browser now uses NacreAppBrowser and app-browser.js; these are fresh
implementations from the behavior spec and actual consumer/tests, not renamed
view bodies. Wallpaper presentation is independently replaced as well.
