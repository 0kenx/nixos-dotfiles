# NixOS Configuration

This repository contains NixOS configuration files for my system, managed with Home Manager.

## Keybinding Philosophy

The keybinding scheme follows a consistent philosophy across applications:

- **SUPER** (Windows key) is the primary modifier for window management in Hyprland
- **ALT** is used for application-specific commands (like in Kitty)
- **CTRL** is used for common operations like copy/paste and combined with other keys for advanced functionality
- **Space** is the leader key in Neovim for plugin commands

## Keybinding Reference

### Hyprland (Window Manager)

#### General

| Keybinding | Action |
|------------|--------|
| `SUPER + T` | Launch Kitty terminal |
| `SUPER + D` | Open application launcher (Rofi) |
| `SUPER + W` | Toggle WiFi |
| `SUPER + Y` | Toggle Bluetooth |
| `SUPER + ESCAPE` | Show logout menu |
| `SUPER + SHIFT + L` | Lock screen |
| `SUPER + SHIFT + Q` | Close active window |
| `SUPER + SHIFT + F` | Toggle floating mode for active window |
| `SUPER + CTRL + F` | Toggle fullscreen mode |
| `SUPER + ALT + M` | Exit Hyprland |

#### Window Management

| Keybinding | Action |
|------------|--------|
| `SUPER + h/j/k/l` | Move focus left/down/up/right |
| `SUPER + arrow keys` | Move focus left/down/up/right |
| `SUPER + ALT + R, then arrow keys/hjkl` | Resize window (enter resize mode) |
| `SUPER + ALT + M, then arrow keys/hjkl` | Move window (enter move mode) |
| `SUPER + mouse drag` | Move window |
| `SUPER + right-click drag` | Resize window |

#### Workspace Management

| Keybinding | Action |
|------------|--------|
| `SUPER + 1-0` | Switch to workspace 1-10 (internal monitor) |
| `SUPER + ALT + 1-0` | Switch to workspace 11-20 (external monitor) |
| `SUPER + SHIFT + 1-0` | Move window to workspace 1-10 |
| `SUPER + ALT + SHIFT + 1-0` | Move window to workspace 11-20 |
| `SUPER + mouse_wheel` | Cycle through workspaces |

#### Media and System Controls

| Keybinding | Action |
|------------|--------|
| `SUPER + p` | Play/pause media |
| `SUPER + [` | Previous track |
| `SUPER + ]` | Next track |
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Toggle mute |
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |

#### Screenshots and Recording

| Keybinding | Action |
|------------|--------|
| `SUPER + SHIFT + S` | Screenshot to clipboard |
| `SUPER + E` | Screenshot and edit |
| `SUPER + SHIFT + R` | Record screen (GIF) |
| `SUPER + R` | Record screen (MP4) |

### Kitty (Terminal)

| Keybinding | Action |
|------------|--------|
| `ALT + SHIFT + T` | New tab |
| `ALT + SHIFT + N` | New window |
| `ALT + SHIFT + W` | Close tab/window |
| `ALT + SHIFT + Q` | Quit Kitty |
| `ALT + SHIFT + F` | Toggle fullscreen |
| `ALT + 1-9` | Switch to tab 1-9 |
| `ALT + h/l` | Previous/next tab |
| `ALT + c` | Copy to clipboard |
| `ALT + v` | Paste from clipboard |
| `ALT + n` | Open new Neovim instance |
| `ALT + SHIFT + +` | Increase font size |
| `ALT + SHIFT + -` | Decrease font size |
| `ALT + SHIFT + 0` | Reset font size |
| `ALT + SHIFT + r` | Reload configuration |

### Neovim (Text Editor)

#### General

| Keybinding | Action |
|------------|--------|
| `SPACE` | Leader key |
| `<Esc>` | Clear search highlighting |
| `SPACE + c` | Close buffer |
| `SPACE + t` | Toggle terminal |
| `CTRL + \` | Toggle terminal (alternative) |
| `SPACE + e` | Toggle file explorer |
| `SPACE + o` | Focus file explorer |
| `SPACE + \\` | Split window vertically |
| `SPACE + -` | Split window horizontally |

#### Window Navigation

| Keybinding | Action |
|------------|--------|
| `CTRL + h/j/k/l` | Navigate between windows |
| `CTRL + arrows` | Resize windows |
| `SHIFT + h/l` | Previous/next buffer |

#### Code Navigation and Editing

| Keybinding | Action |
|------------|--------|
| `gd` | Go to definition |
| `K` | Show hover information |
| `SPACE + rn` | Rename symbol |
| `SPACE + ca` | Code action |
| `gr` | Show references |
| `SPACE + ld` | Show diagnostics |
| `[d` | Previous diagnostic |
| `]d` | Next diagnostic |
| `SPACE + lf` | Format code |
| `ALT + j/k` | Move line down/up |
| `<` / `>` (in visual mode) | Indent/outdent |

#### Search and Files

| Keybinding | Action |
|------------|--------|
| `SPACE + ff` | Find files |
| `SPACE + fg` | Find in files (grep) |
| `SPACE + fb` | Find buffers |
| `SPACE + fh` | Find help |
| `SPACE + fp` | Find recent files |
| `SPACE + fc` | Find in current buffer |

#### Git

| Keybinding | Action |
|------------|--------|
| `SPACE + gs` | Git status |
| `SPACE + gl` | Git blame |
| `SPACE + gj/k` | Next/previous git hunk |
| `SPACE + gp` | Preview git hunk |
| `SPACE + gr` | Reset git hunk |
| `SPACE + gR` | Reset buffer |
| `SPACE + gs` | Stage hunk |
| `SPACE + gu` | Unstage hunk |
| `SPACE + gd` | Git diff |

## Consistent Patterns

To maintain consistency across applications, similar actions use similar keybindings:

- **Tab navigation**: `ALT + h/l` in Kitty, `SHIFT + h/l` in Neovim
- **Window navigation**: `SUPER + h/j/k/l` in Hyprland, `CTRL + h/j/k/l` in Neovim
- **Leader keys**: `SUPER` in Hyprland, `SPACE` in Neovim, `ALT` in Kitty
- **Terminal**: `SUPER + T` to open Kitty, `SPACE + t` to toggle terminal in Neovim
- **File operations**: `SPACE + e/o` in Neovim to toggle/focus file explorer, `SUPER + F` in Hyprland to open file manager
- **Quitting**: `SUPER + SHIFT + Q` to close window in Hyprland, `ALT + SHIFT + Q` to quit Kitty
- **Movement**: `hjkl` keys for directional movement in both Hyprland and Neovim