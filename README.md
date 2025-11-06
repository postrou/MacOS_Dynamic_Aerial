# Aerial Wallpaper Switcher for macOS

Automatic switching of MacOS video wallpapers and screensavers (Morning/Day/Evening/Night) based on time of day in MacOS 15+ (Sequoia/Tahoe). This simulates the behavior of MacOS dynamic wallpapers, but with video wallpapers from "Landscape/Cityscape/...". As example, we take Tahoe Morning/Day/Evening/Night wallpapers.

## Requirements

- MacOS 15+ (Tahoe)
- Tahoe video wallpapers from System Settings

## Installation

1. Clone the repository:
```bash
git clone https://github.com/postrou/macos_dynamic_aerial.git
cd macos_dynamic_aerial
```

2. Run the installer:
```bash
bash install.sh
```

3. Create profiles for each time of day:

**For Tahoe Morning:**
- Open System Settings → Wallpaper & Screensaver
- Select Tahoe Morning
- Wait for video to download
- Save the profile:
```bash
cp ~/Library/Application\ Support/com.apple.wallpaper/Store/Index.plist ~/.aerial/Tahoe-Morning.plist
```

**Repeat for Tahoe Day, Evening, Night:**
```bash
cp ~/Library/Application\ Support/com.apple.wallpaper/Store/Index.plist ~/.aerial/Tahoe-Day.plist
cp ~/Library/Application\ Support/com.apple.wallpaper/Store/Index.plist ~/.aerial/Tahoe-Evening.plist
cp ~/Library/Application\ Support/com.apple.wallpaper/Store/Index.plist ~/.aerial/Tahoe-Night.plist
```

## Switching Schedule

- **06:00** — Tahoe Morning
- **12:00** — Tahoe Day
- **18:00** — Tahoe Evening
- **22:00** — Tahoe Night

To change the times, edit `aerial_dispatch.sh` before installation.

## Management

### Check status
```bash
launchctl list | grep aerial
```

### Logs
```bash
tail -f ~/Library/Logs/aerial.switcher.err.log
tail -f ~/Library/Logs/aerial.switcher.out.log
```

### Manual test
```bash
bash ~/.aerial/aerial_dispatch.sh
```

### Stop agent
```bash
launchctl bootout gui/$(id -u)/com.$(whoami).aerial.switcher
```

### Uninstall
```bash
bash uninstall.sh
```

## Troubleshooting

**Agent won't start:**
```bash
plutil -lint ~/Library/LaunchAgents/com.*.aerial.switcher.plist
cat ~/Library/Logs/aerial.switcher.err.log
```

**Profiles not found:**
Make sure you created all four .plist files in `~/.aerial/`

**Bootstrap failed: 5:**
```bash
launchctl remove com.$(whoami).aerial.switcher
bash install.sh
```

## License

MIT
