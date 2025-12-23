<div align="center">
  <img src="https://private-user-images.githubusercontent.com/1794388/483874013-07d05cd0-d5dc-4a28-9a35-51bae8f119a0.svg?jwt=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJnaXRodWIuY29tIiwiYXVkIjoicmF3LmdpdGh1YnVzZXJjb250ZW50LmNvbSIsImtleSI6ImtleTUiLCJleHAiOjE3NjY1MDMzMTYsIm5iZiI6MTc2NjUwMzAxNiwicGF0aCI6Ii8xNzk0Mzg4LzQ4Mzg3NDAxMy0wN2QwNWNkMC1kNWRjLTRhMjgtOWEzNS01MWJhZThmMTE5YTAuc3ZnP1gtQW16LUFsZ29yaXRobT1BV1M0LUhNQUMtU0hBMjU2JlgtQW16LUNyZWRlbnRpYWw9QUtJQVZDT0RZTFNBNTNQUUs0WkElMkYyMDI1MTIyMyUyRnVzLWVhc3QtMSUyRnMzJTJGYXdzNF9yZXF1ZXN0JlgtQW16LURhdGU9MjAyNTEyMjNUMTUxNjU2WiZYLUFtei1FeHBpcmVzPTMwMCZYLUFtei1TaWduYXR1cmU9YTczMGUyM2MyMTc5NWVkM2I2N2FiOTcyZDVkNmM5NWQwNzZjMzU0NmY1MGNmNzYyZjJjZmNiMjI3NmM2YmI4NyZYLUFtei1TaWduZWRIZWFkZXJzPWhvc3QifQ.D-1XpnX1aUGvsCnYIBD7HzdHNkSwA3-Z1LW32WejpKY" alt="Niri Logo" width="120"/>
  
  # Nirifiles
  
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=28&duration=3000&pause=1000&color=F7768E&center=true&vCenter=true&width=435&lines=Nirifiles;Niri+Configuration;Scrollable+Tiling+Wayland" alt="Typing SVG" />
</div>

---

<div align="center">
  
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=35&duration=2000&pause=1000&color=7DCFFF&center=true&vCenter=true&width=435&lines=About+Niri" alt="About Niri" />
  
</div>

Niri is a scrollable-tiling Wayland compositor with a fresh approach to window management. Unlike traditional tiling window managers, Niri arranges windows in columns on an infinite strip that you can scroll through horizontally. Each workspace contains these scrollable columns, giving you unlimited horizontal space while maintaining the efficiency of tiling. Built in Rust with performance in mind, Niri features smooth animations powered by custom GLSL shaders, dynamic layouts that adapt to your workflow, and native Wayland protocols for maximum compatibility.

**Key Features:** Scrollable column-based layout, Custom GLSL shader animations, Dynamic window sizing, Native Wayland support, Infinite horizontal workspace, Column stacking and tabbing

**Official Resources:** [GitHub](https://github.com/YaLTeR/niri) • [Documentation](https://github.com/YaLTeR/niri/wiki) • [Wiki](https://github.com/YaLTeR/niri/wiki/Configuration:-Overview)

<div align="center">
  
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=35&duration=2000&pause=1000&color=7AA2F7&center=true&vCenter=true&width=435&lines=Dependencies" alt="Dependencies" />
  
</div>

<table>
<tr>
<td width="50%" valign="top">

### Core System
| Package | Purpose |
|---------|---------|
| `niri` | Wayland compositor |
| `waybar` | Status bar |
| `swaybg` | Wallpaper daemon |
| `walker` | Application launcher |
| `foot` | Terminal emulator |
| `ttf-jetbrains-mono` | JetBrains Mono font |
| `ttf-jetbrains-mono-nerd` | JetBrains Nerd font |
| `ttf-pragmasevka-nerd-font` | Pragmasevka Nerd font |

### Applications
| Package | Purpose |
|---------|---------|
| `firefox` | Web browser |
| `spotify-launcher` | Music streaming |
| `gnome-calendar` | Calendar app |
| `gnome-calculator` | Calculator |
| `gnome-disks-utility` | Disk management |
| `gnome-photos` | Photo viewer |
| `evince-no-gnome` | Document viewer |
| `pacseek` | Package manager TUI |
| `ayugram-desktop-bin` | Telegram client |
| `zed` | Code editor |

</td>
<td width="50%" valign="top">

### Utilities & Tools
| Package | Purpose |
|---------|---------|
| `swaylock` | Screen locker |
| `satty` | Screenshot editor |
| `inotify-tools` | File system monitoring |
| `wireplumber` | Audio management |
| `playerctl` | Media control |
| `brightnessctl` | Brightness control |
| `wl-clipboard` | Clipboard manager |

### Installation

**Core System:**
```bash
# Arch-based systems
yay -S niri waybar swaybg walker foot \
       ttf-jetbrains-mono ttf-jetbrains-mono-nerd \
       ttf-pragmasevka-nerd-font
```

**Applications:**
```bash
yay -S firefox spotify-launcher gnome-calendar \
       gnome-calculator gnome-disks-utility \
       gnome-photos evince-no-gnome pacseek \
       ayugram-desktop-bin zed
```

**Utilities & Tools:**
```bash
yay -S swaylock satty inotify-tools \
       wireplumber playerctl brightnessctl \
       wl-clipboard
```

**Start Niri:**
```bash
# From TTY
niri-session

# Or with display manager (SDDM)
sudo pacman -S sddm
sudo systemctl enable sddm --now
```

</td>
</tr>
</table>

<div align="center">
  
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=35&duration=2000&pause=1000&color=9ECE6A&center=true&vCenter=true&width=435&lines=Keybindings" alt="Keybindings" />
  
</div>

<table>
<tr>
<td width="50%" valign="top">

### System Control
| Keybind | Action |
|---------|--------|
| `Super + Shift + E` | Quit compositor |
| `Super + Q` | Close window |
| `Super + Shift + /` | Show hotkey overlay |
| `Super + Alt + L` | Lock screen |
| `Super + Shift + P` | Power off monitors |
| `Super + Escape` | Toggle shortcuts inhibit |

### Launch Applications
| Keybind | Action |
|---------|--------|
| `Super + D` | Application launcher (Walker) |
| `Super + Return` | Terminal (Foot) |
| `Super + T` | Terminal (Foot) |
| `Super + N` | Neovim in terminal |
| `Super + B` | Firefox |
| `Super + E` | File manager (Nautilus) |
| `Super + Shift + M` | Spotify |
| `Super + Shift + C` | Calendar |
| `Super + Space` | Window switcher (Vicinae) |

### Window Focus
| Keybind | Action |
|---------|--------|
| `Super + H/J/K/L` | Focus direction (Vim) |
| `Super + Arrow Keys` | Focus direction (Arrows) |

### Window Movement
| Keybind | Action |
|---------|--------|
| `Super + Ctrl + H/J/K/L` | Move window (Vim) |
| `Super + Ctrl + Arrow Keys` | Move window (Arrows) |

### Monitor Management
| Keybind | Action |
|---------|--------|
| `Super + Shift + H/L` | Focus monitor |
| `Super + Shift + Arrow Keys` | Focus monitor |
| `Super + Shift + Ctrl + H/L` | Move to monitor |
| `Super + Shift + Ctrl + Arrow Keys` | Move to monitor |

### Workspace Navigation
| Keybind | Action |
|---------|--------|
| `Super + 1-9` | Switch to workspace |
| `Super + Scroll Wheel` | Cycle workspaces |
| `Super + O` | Toggle overview mode |

</td>
<td width="50%" valign="top">

### Move Window to Workspace
| Keybind | Action |
|---------|--------|
| `Super + Ctrl + 1-9` | Move window to workspace |

### Column Management
| Keybind | Action |
|---------|--------|
| `Super + [` | Consume/expel window left |
| `Super + ]` | Consume/expel window right |
| `Super + ,` | Consume window into column |
| `Super + .` | Expel window from column |
| `Super + W` | Toggle column tabbed display |

### Window Sizing
| Keybind | Action |
|---------|--------|
| `Super + R` | Switch preset column width |
| `Super + Shift + R` | Switch preset window height |
| `Super + Ctrl + R` | Reset window height |
| `Super + M` | Maximize column |
| `Super + Shift + F` | Fullscreen window |
| `Super + F` | Maximize column |
| `Super + C` | Center column |
| `Super + -` | Decrease column width |
| `Super + =` | Increase column width |
| `Super + Shift + -` | Decrease window height |
| `Super + Shift + =` | Increase window height |

### Floating Windows
| Keybind | Action |
|---------|--------|
| `Super + V` | Toggle window floating |
| `Super + Shift + V` | Switch float/tiling focus |

### Screenshots
| Keybind | Action |
|---------|--------|
| `Super + S` | Screenshot → Satty editor → Auto-copy |

### Media Controls
| Keybind | Action |
|---------|--------|
| `XF86AudioRaiseVolume` | Volume up |
| `XF86AudioLowerVolume` | Volume down |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioMicMute` | Toggle mic mute |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioStop` | Stop |
| `XF86AudioPrev` | Previous track |
| `XF86AudioNext` | Next track |
| `XF86MonBrightnessUp` | Brightness up |
| `XF86MonBrightnessDown` | Brightness down |

</td>
</tr>
</table>

<div align="center">
  
  <img src="https://readme-typing-svg.demolab.com?font=Fira+Code&size=35&duration=2000&pause=1000&color=BB9AF7&center=true&vCenter=true&width=435&lines=Previews" alt="Previews" />
  
</div>

![Preview 1](https://github.com/user-attachments/assets/b20321bd-0954-4dbc-9d06-dbff5a18f82b)

![Preview 2](https://github.com/user-attachments/assets/d7696245-2c79-49f0-a1f6-6c9b593c7a3c)

![Preview 3](https://github.com/user-attachments/assets/ac3951d6-294b-466a-a793-96a8f65b35a0)
