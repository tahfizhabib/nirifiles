# niriha

<p align="center">
  <b>A personal Quickshell setup for the Niri Wayland compositor.</b><br/>
  Minimal, fast, and built to stay out of the way. Gruvbox only for now, more themes coming later.
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Compositor-Niri-1d2021?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Shell-Quickshell-458588?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Theme-Gruvbox-d65d0e?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Stage-Early%20Access-b16286?style=for-the-badge&logoColor=white" />
  <img src="https://img.shields.io/badge/Size-~150kb-689d6a?style=for-the-badge&logoColor=white" />
</p>

<br/>

> [!WARNING]
> This is a personal config built for a specific machine and workflow.
> It is not designed to work out of the box on every system.
> **Use only as a reference.**

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=0,2,2,5,30&height=4&section=header" width="100%"></picture>

## Preview

<p align="center">
  <a href="https://github.com/user-attachments/assets/4b2b9e1d-b28e-4f67-b19f-11eb0724810f">
    <img src="https://github.com/user-attachments/assets/4b2b9e1d-b28e-4f67-b19f-11eb0724810f" width="49%" style="border:2px solid #30363d;border-radius:8px;margin:3px" />
  </a>
  <a href="https://github.com/user-attachments/assets/21a9844e-98c5-4016-9c62-ee015559af9d">
    <img src="https://github.com/user-attachments/assets/21a9844e-98c5-4016-9c62-ee015559af9d" width="49%" style="border:2px solid #30363d;border-radius:8px;margin:3px" />
  </a>
</p>
<p align="center">
  <a href="https://github.com/user-attachments/assets/0c1fb403-99ca-4aeb-9f32-e644ae9e0e36">
    <img src="https://github.com/user-attachments/assets/0c1fb403-99ca-4aeb-9f32-e644ae9e0e36" width="49%" style="border:2px solid #30363d;border-radius:8px;margin:3px" />
  </a>
  <a href="https://github.com/user-attachments/assets/989865a8-a058-4cc7-9724-b404392e5080">
    <img src="https://github.com/user-attachments/assets/989865a8-a058-4cc7-9724-b404392e5080" width="49%" style="border:2px solid #30363d;border-radius:8px;margin:3px" />
  </a>
</p>

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=6,11,20&height=4&section=header" width="100%"></picture>

## Features

<table width="100%">
  <tr>
    <td valign="top" width="50%" style="padding:16px">
      <h3 align="center">Implemented</h3>
      <ul>
        <li>
          <b>Status Bar</b><br/>
          Always-on bar with workspace indicators, clock, and quick controls.
          Right-click anywhere on the bar to open the Control Center.
        </li>
        <li>
          <b>Workspace Layout</b><br/>
          Visual overview of all active Niri workspaces.
        </li>
        <li>
          <b>Application Launcher</b><br/>
          Keyboard-driven app search and launch.
        </li>
        <li>
          <b>Wallpaper Picker</b><br/>
          Browse and apply wallpapers from <code>~/Wallpapers/</code> powered by swww.
        </li>
        <li>
          <b>Status Monitor</b><br/>
          CPU, RAM, and temperature readouts. Reads directly from <code>/proc</code>, no extra tools needed.
        </li>
        <li>
          <b>Calendar</b><br/>
          Date display with a toggleable calendar popup.
        </li>
        <li>
          <b>Control Center</b><br/>
          Volume, brightness, network, Bluetooth, power profile, and media controls in one panel.
          The media card only shows when an active MPRIS player is running.
        </li>
      </ul>
    </td>
    <td valign="top" width="50%" style="padding:16px">
      <h3 align="center">Planned</h3>
      <ul>
        <li>
          <b>Power Menu</b><br/>
          Shutdown, reboot, suspend, and logout actions.
        </li>
        <li>
          <b>Shaders</b><br/>
          Post-processing visual effects layer.
        </li>
        <li>
          <b>Wifi / Bluetooth Panel</b><br/>
          Dedicated network and connection management panel.
        </li>
        <li>
          <b>Lockscreen</b><br/>
          Integrated lock screen styled to match the rest of the config.
        </li>
        <li>
          <b>File Search and Emoji Picker</b><br/>
          System-wide file search and a searchable emoji selection popup.
        </li>
        <li>
          <b>Clipboard Viewer</b><br/>
          Clipboard history panel.
        </li>
        <li>
          <b>Multi-theme Support</b><br/>
          A custom lightweight theming engine to replace the hardcoded Gruvbox palette.
        </li>
      </ul>
    </td>
  </tr>
</table>

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=12,19,28&height=4&section=header" width="100%"></picture>

## Installation

The whole config is around **150kb**. No frameworks, no plugin managers. Just Quickshell and the packages listed below, most of which are already on a standard Niri system.

### 1. Install Dependencies

| Package | Purpose |
|---|---|
| `quickshell` | Shell framework |
| `niri` | Wayland compositor |
| `swww` | Wallpaper daemon |
| `pipewire` + `wireplumber` + `wpctl` | Audio and volume control |
| `brightnessctl` | Display brightness control |
| `playerctl` | MPRIS media player control |
| `networkmanager` (`nmcli`) | WiFi management |
| `bluez` + `bluetoothctl` | Bluetooth |
| `power-profiles-daemon` | Power profile switching |
| `qt6-svg` | Qt6 SVG rendering |
| `qt6-imageformats` | PNG and WebP icon rendering in Quickshell |
| `imagemagick` | Image processing for certain Quickshell builds |
| `foot` | Terminal (any terminal works) |

**Font:** [Google Sans](https://fonts.google.com/specimen/Google+Sans) is used throughout the bar and UI. Install it before launching.

**Icon Theme:** Any XDG-compliant theme works. [Papirus](https://github.com/PapirusDevelopmentTeam/papirus-icon-theme) is recommended. After installing, set it at the top of `shell.qml`:

```qml
//@ pragma IconTheme Papirus
```

### 2. Clone and Copy

This repo ships the complete `~/.config/` layout. Niri, Foot, and Quickshell configs all sit in their expected locations. Clone and drop everything in:

```sh
git clone https://github.com/yourusername/niriha
cp -r niriha/.config/* ~/.config/
```

> [!NOTE]
> Back up your existing Niri and Foot configs before running the copy command. It will overwrite whatever is already there.

### 3. Launch

Run it directly from the terminal:

```sh
quickshell -c niriha
```

To start it automatically on login, add this to `~/.config/niri/config.kdl`:

```kdl
spawn-at-startup "quickshell" "-c" "niriha"
```

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=24,30,6&height=4&section=header" width="100%"></picture>

## Keybinds

All components are exposed over Quickshell IPC. The included `config.kdl` already has these wired up. If you are using your own existing Niri config, add the binds manually:

```kdl
binds {
    Mod+Space { spawn "sh" "-c" "qs ipc -c niriha call launcher toggle"; }
    Mod+C     { spawn "sh" "-c" "qs ipc -c niriha call controlcenter toggle"; }
    Mod+W     { spawn "sh" "-c" "qs ipc -c niriha call wallpaper toggle"; }
    Mod+A     { spawn "sh" "-c" "qs ipc -c niriha call calendar toggle"; }
    Mod+S     { spawn "sh" "-c" "qs ipc -c niriha call stats toggle"; }
}
```

You can also call any component from the terminal directly without touching the config:

```sh
qs ipc -c niriha call launcher toggle
qs ipc -c niriha call controlcenter toggle
qs ipc -c niriha call wallpaper toggle
qs ipc -c niriha call calendar toggle
qs ipc -c niriha call stats toggle
```

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=3,9,17&height=4&section=header" width="100%"></picture>

## Config Structure

```
~/.config/
├── quickshell/
│   └── niriha/        # Quickshell config (this repo)
├── niri/
│   └── config.kdl     # Niri config with IPC keybinds and bar exclusion zone
└── foot/
    └── foot.ini       # Foot terminal config
```

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=15,22,4&height=4&section=header" width="100%"></picture>

## Notes

- **Resolution.** The bar is built and tested at 1080p. For other resolutions, tweak the margins in `ActionBar.qml`.
- **Bar exclusion zone.** The included `config.kdl` sets `struts { top 30; }` so windows do not go under the bar. If you are using your own Niri config, add this manually.
- **Wallpapers.** Drop wallpapers into `~/Wallpapers/`. That is the directory the picker reads from.
- **Media card.** The Control Center media card only shows when an MPRIS player such as mpv, Spotify, or Firefox is actively running.
- **Right-click.** Right-clicking anywhere on the status bar opens the Control Center, same as the IPC keybind.
- **System stats.** CPU, RAM, and temperature data is read from `/proc` directly. No monitoring tools needed.

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=8,18,25&height=4&section=header" width="100%"></picture>

## FAQ

**Why Quickshell?**

Most shell options for Wayland either pull in a heavy runtime or require learning a new config format. Quickshell keeps the whole thing at around 150kb. The dependencies it needs are packages any Niri setup will already have. No plugin manager, no daemon, no extra steps. Copy the folder, run the command.

**Why no theming support yet?**

Getting theming right means every color has to map correctly across every component. matugen, HeroUI, and pywal were all tested. None of them were accurate enough in practice. The palette values came out technically valid but visually wrong in ways that mattered. The plan is to write a small purpose-built theming layer that handles this properly. Gruvbox stays hardcoded until that exists.

**Why is the status bar not modular?**

This is a daily-use personal config, not a general-purpose framework. Only things that actually get used are here. Building out modularity and plugin support is a different kind of project with different maintenance requirements. The code is readable if you want to adapt something from it.

**Will this work on my machine?**

If you already run Niri, dropping this into `~/.config/` and running `quickshell -c niriha` should be enough to get it going. The keybinds are in `config.kdl` and the bar exclusion zone is already set. If you have your own Niri config, copy the `binds` block over and add `struts { top 30; }`. If you are setting up Niri from scratch, this gives you a working starting point.

<picture><img src="https://capsule-render.vercel.app/api?type=rect&color=gradient&customColorList=27,5,13&height=4&section=header" width="100%"></picture>

## Credits

<table>
  <tr>
    <td valign="top" style="padding:12px">
      <b><a href="https://github.com/tahfizhabib">@tahfizhabib</a></b><br/>
      FOSS enthusiast. Builds things out of daily use and a preference for software that does its job without getting in the way.<br/>
      niriha started as a scratch-built replacement for everything that felt too heavy or too generic on Niri.
    </td>
  </tr>
</table>

Built on top of [Quickshell](https://quickshell.outfoxxed.me) and [Niri](https://github.com/YaLTeR/niri).
