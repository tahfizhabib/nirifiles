#!/bin/bash

choice=$(printf "Lock\nLogout\nSuspend\nReboot\nShutdown" | fuzzel --dmenu)

case "$choice" in
    Lock) swaylock -f ;;
    Logout) niri msg action quit ;;
    Suspend) systemctl suspend ;;
    Reboot) systemctl reboot ;;
    Shutdown) systemctl poweroff ;;
esac
