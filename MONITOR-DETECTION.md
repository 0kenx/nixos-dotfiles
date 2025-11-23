# Monitor Detection System

This NixOS configuration includes a dynamic monitor detection system that persists across `nixos-rebuild switch` operations.

## How It Works

### 1. Monitor Detection by Serial Number

The system detects monitors using their serial numbers (defined in `nixos/hosts/workstation/default.nix`):
- **Primary**: VNA6R2XB (Lenovo S28u-10)
- **Secondary**: VNA6R2XA (Lenovo S28u-10, vertical orientation)

Detection happens at runtime and maps serial numbers to actual port names (e.g., HDMI-A-1, DP-8).

### 2. Detection Cache

Monitor detection results are cached in `~/.cache/hypr/monitor-detection`:
```bash
PRIMARY=HDMI-A-1
SECONDARY=DP-8
TERTIARY=
```

This cache allows the configuration to persist between Hyprland restarts and system rebuilds.

### 3. Dynamic Waybar Configuration

Waybar uses a wrapper (`nixos/home/waybar.nix`) that:
1. Reads the monitor detection cache
2. Processes the static config file with sed to replace `@PRIMARY@`, `@SECONDARY@`, `@TERTIARY@` placeholders
3. Launches Waybar with the runtime-generated configuration

This ensures Waybar bars appear on the correct monitors regardless of port name changes.

## After nixos-rebuild switch

When you run `sudo nixos-rebuild switch`, monitors may not be reconfigured automatically. To fix this:

```bash
hypr-monitor-setup
```

This command will:
1. Re-detect monitors by serial number
2. Apply correct monitor configuration (position, rotation, scale)
3. Update the detection cache
4. Reload Waybar to use the new monitor assignments

## Files Modified

- **nixos/home/hyprland.nix** (lines 40-161):
  - `monitorDetectionScript`: Detects monitors and caches results
  - `monitorSetupScript`: Applies monitor config and reloads Waybar
  - Added `hypr-monitor-setup` command for manual invocation

- **nixos/home/waybar.nix** (lines 1-36):
  - Created `waybarWrapper` that processes config at runtime
  - Replaced hardcoded monitor names with `@PRIMARY@`, `@SECONDARY@`, `@TERTIARY@` placeholders (lines 46, 102, 339, 380)

## Troubleshooting

### Waybar not showing on second monitor
Run: `hypr-monitor-setup`

### Monitors have wrong orientation/position
Run: `hypr-monitor-setup`

### Cache not updating
Delete the cache and re-run detection:
```bash
rm ~/.cache/hypr/monitor-detection
hypr-monitor-setup
```

### Check current monitor status
```bash
hyprctl monitors
cat ~/.cache/hypr/monitor-detection
```

## Future Improvements

Consider adding a systemd user service or home-manager activation script to automatically run `hypr-monitor-setup` after system switches.
