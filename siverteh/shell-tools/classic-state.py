#!/usr/bin/env python3
"""Commit one wallpaper palette to the shell, window frame and native choosers."""
import json, os, re, signal, subprocess, sys, tempfile
from pathlib import Path


def atomic_write(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    fd, temp = tempfile.mkstemp(prefix='.' + path.name, dir=path.parent)
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(text)
        os.replace(temp, path)
    finally:
        if os.path.exists(temp): os.unlink(temp)


def apply_palette(home, wallpaper=None, live=True):
    state = home / '.local/state/siverteh_shell'
    data = json.loads((state / 'scheme.json').read_text())
    colors = {k: v.lstrip('#') for k, v in data['colours'].items()}
    if any(not re.fullmatch('[0-9a-fA-F]{6}', v) for v in colors.values()):
        raise ValueError('Invalid palette color')
    # Validate required roles before publishing any state.
    primary, secondary, inactive, shadow = (colors[k] for k in ('primary', 'secondary', 'outlineVariant', 'shadow'))
    lua = 'hl.config({general={col={active_border={colors={"rgba(' + primary + 'ff)","rgba(' + secondary + 'ff)"},angle=45},inactive_border="rgba(' + inactive + 'aa)"}},decoration={shadow={color="rgba(' + shadow + '40)"}}})\n'
    atomic_write(home / '.config/siverteh-shell/palette.lua', lua)
    template = Path(__file__).with_name('rofi.rasi').read_text()
    roles = {'bg':'surface', 'raised':'surfaceContainer', 'text':'onSurface', 'muted':'onSurfaceVariant', 'accent':'primary', 'border':'outlineVariant'}
    for token, role in roles.items():
        template = re.sub(r'\b' + token + r': #[0-9a-fA-F]{6};', token + ': #' + colors[role] + ';', template)
    atomic_write(home / '.config/siverteh-shell/rofi.rasi', template)
    # GTK and qtct use the same committed palette, rather than the old blue files.
    gtk_roles = {'accent_color':'primary', 'accent_bg_color':'primary', 'accent_fg_color':'onPrimary',
                 'window_bg_color':'surface', 'window_fg_color':'onSurface',
                 'headerbar_bg_color':'surfaceContainer', 'headerbar_fg_color':'onSurface',
                 'popover_bg_color':'surfaceContainer', 'popover_fg_color':'onSurface',
                 'view_bg_color':'surface', 'view_fg_color':'onSurface',
                 'card_bg_color':'surfaceContainerLow', 'card_fg_color':'onSurface',
                 'theme_bg_color':'surface', 'theme_fg_color':'onSurface',
                 'theme_base_color':'surface', 'theme_text_color':'onSurface',
                 'theme_selected_bg_color':'primary', 'theme_selected_fg_color':'onPrimary'}
    gtk = ''.join('@define-color '+name+' #'+colors[role]+';\n' for name,role in gtk_roles.items())
    for version in ('3.0', '4.0'):
        directory = home / ('.config/gtk-' + version)
        atomic_write(directory/'gtk.css', gtk)
        settings = directory/'settings.ini'
        if settings.exists():
            text = settings.read_text()
            text = re.sub(r'(?m)^gtk-application-prefer-dark-theme\s*=.*$', 'gtk-application-prefer-dark-theme='+('1' if data['mode']=='dark' else '0'), text)
            text = re.sub(r'(?m)^gtk-theme-name\s*=.*$', 'gtk-theme-name=Adwaita'+('-dark' if data['mode']=='dark' else ''), text)
            atomic_write(settings, text)
    # Numeric order follows Qt QPalette::ColorRole, including Accent in Qt 6.
    qt_roles = ['onSurface','surfaceContainer','surfaceBright','surfaceContainerHigh','surfaceDim',
                'outlineVariant','onSurface','onPrimary','onSurface','surface','surface','shadow',
                'primary','onPrimary','primary','tertiary','surfaceContainerLow','onSurface',
                'surfaceContainer','onSurface','onSurfaceVariant','primary']
    qt = '[ColorScheme]\n'+''.join(group+'_colors='+', '.join('#ff'+colors[role] for role in qt_roles)+'\n' for group in ('active','inactive','disabled'))
    qt_path = home/'.config/siverteh-shell/qt.conf'
    atomic_write(qt_path, qt)
    for version in (5, 6):
        settings=home/f'.config/qt{version}ct/qt{version}ct.conf'
        if settings.exists():
            text = re.sub(r'(?m)^color_scheme_path\s*=.*$', 'color_scheme_path='+str(qt_path), settings.read_text())
            text = re.sub(r'(?m)^custom_palette\s*=.*$', 'custom_palette=true', text)
            atomic_write(settings, text)
    # Existing updater prompts and terminal apps share the committed colors too.
    for name,role in {'primary':'primary','secondary':'secondary','onsurface':'onSurface','onprimary':'onPrimary','surface':'surface','surfacecontainer':'surfaceContainer'}.items():
        atomic_write(home/('.config/siverteh/core/colors/'+name), '#'+colors[role])
    legacy='\n'.join('var_'+name+' = "rgba('+colors[role]+'ff)"' for name,role in [('primary','primary'),('on_primary','onPrimary'),('on_surface','onSurface')])+'\n'
    atomic_write(home/'.config/hypr/colors.lua', legacy)
    terminal_roles={'foreground':'onSurface','background':'surface','cursor':'primary','cursor_text_color':'onPrimary',
                    'selection_foreground':'onPrimary','selection_background':'primary','url_color':'tertiary',
                    'active_border_color':'primary','inactive_border_color':'outlineVariant',
                    'active_tab_foreground':'onPrimary','active_tab_background':'primary',
                    'inactive_tab_foreground':'onSurfaceVariant','inactive_tab_background':'surfaceContainer'}
    terminal=''.join(name+' #'+colors[role]+'\n' for name,role in terminal_roles.items())
    ansi=['surfaceVariant','error','green','yellow','blue','mauve','teal','onSurface']
    for i,role in enumerate(ansi):
        value=colors.get(role,colors['primary'])
        terminal+=f'color{i} #{value}\ncolor{i+8} #{value}\n'
    atomic_write(home/'.config/kitty/colors-matugen.conf', terminal)
    lock_template=Path(__file__).with_name('hyprlock.conf.in').read_text()
    selected = str(Path(wallpaper).expanduser().resolve()) if wallpaper else ((state/'wallpaper/last.txt').read_text().strip() if (state/'wallpaper/last.txt').exists() else '')
    lock_template=lock_template.replace('{{wallpaper}}', selected)
    for role,value in colors.items():lock_template=lock_template.replace('{{'+role+'}}',value)
    atomic_write(home/'.config/hypr/hyprlock.conf', lock_template)

    atomic_write(state / 'scheme/current-mode.txt', data['mode'])
    atomic_write(state / 'scheme/current.txt', '\n'.join(k+' '+v for k,v in colors.items())+'\n')
    if wallpaper is not None:
        atomic_write(state / 'wallpaper/last.txt', str(Path(wallpaper).expanduser().resolve()))
    if live:
        # Kitty documents SIGUSR1 as a config reload; it leaves terminal sessions running.
        for proc in Path('/proc').iterdir():
            if not proc.name.isdigit():continue
            try:
                if proc.stat().st_uid==os.getuid() and (proc/'comm').read_text().strip()=='kitty':os.kill(int(proc.name),signal.SIGUSR1)
            except (OSError,ProcessLookupError):pass
        subprocess.run(['gsettings','set','org.gnome.desktop.interface','color-scheme','prefer-'+data['mode']], capture_output=True)
        subprocess.run(['gsettings','set','org.gnome.desktop.interface','gtk-theme','Adwaita'+('-dark' if data['mode']=='dark' else '')], capture_output=True)
        result = subprocess.run(['hyprctl', 'eval', lua], capture_output=True, text=True)
        if result.returncode:
            print('Palette saved; live window-border update failed: ' + result.stderr.strip(), file=sys.stderr)


if __name__ == '__main__':
    apply_palette(Path.home(), sys.argv[1] if len(sys.argv)>1 else None)
