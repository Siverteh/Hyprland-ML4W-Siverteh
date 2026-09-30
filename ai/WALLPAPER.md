# Wallpaper renderer repair

Wallpaper selection uses Waypaper's native `awww` backend. Pretending awww is
swww through local aliases makes Waypaper stop the real renderer as a competing
backend. The selected engine, Waypaper configuration, and apply script must agree.
The installer removes only this repository's obsolete swww symlinks. Reapply
the current image with native awww and verify that the renderer PID remains stable.

Restore the previous wallpaper scripts, engine setting, Waypaper configuration,
and aliases from the dated deployment backup to roll back this repair. Preserve
the user's other dotfile changes.
