-- One owner per desktop function. UWSM handles the graphical session and XDG autostart.
hl.on("hyprland.start", function()
    hl.exec_cmd("uwsm app -t scope -- /usr/lib/pam_kwallet_init")
    hl.exec_cmd("uwsm app -- /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("uwsm app -- wl-paste --watch cliphist store")
    hl.exec_cmd("uwsm app -- ~/.config/hypr/scripts/low-battery.sh")
    hl.exec_cmd("uwsm app -- ~/.config/hypr/scripts/coding-setup.sh")
end)
