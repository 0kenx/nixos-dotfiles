# Keybindings Reference

Arrow-based navigation system optimized for split keyboard layouts. Consistent modifier patterns across all applications.

## Table of Contents
- [Neovim](#neovim)
  - [Cursor Navigation](#cursor-navigation)
  - [Window Management](#window-management)
  - [Buffer Navigation](#buffer-navigation)
  - [File Explorer](#file-explorer)
  - [Terminal](#terminal)
  - [Telescope (Fuzzy Finder)](#telescope-fuzzy-finder)
  - [LSP (Language Server)](#lsp-language-server)
  - [Git Operations](#git-operations)
  - [AI / Copilot](#ai--copilot)
- [Hyprland (OS Window Manager)](#hyprland-os-window-manager)
- [Navigation Pattern Consistency](#navigation-pattern-consistency)

---

## Neovim

### Cursor Navigation

**Basic Movement**
- `← → ↑ ↓` - Character movement (default vim behavior)
- `hjkl` - Alternative character movement (vim classic)

**Long Jumps**
- `Ctrl+Left` - Jump word backward (equivalent to `b`)
- `Ctrl+Right` - Jump word forward (equivalent to `w`)
- `Ctrl+Up` - Jump paragraph up (equivalent to `{`)
- `Ctrl+Down` - Jump paragraph down (equivalent to `}`)

**Visual Selection**
- `Shift+Left/Right/Up/Down` - Start/extend visual selection
- Works in both normal mode (starts selection) and visual mode (extends)

**Text Movement**
- `Alt+j` - Move current line down
- `Alt+k` - Move current line up
- Works with visual selections to move multiple lines

### Window Management

**Navigation**
- `Alt+Left` - Move to left window
- `Alt+Down` - Move to down window
- `Alt+Up` - Move to up window
- `Alt+Right` - Move to right window
- `Ctrl+h/j/k/l` - Alternative (vim classic)

**Swapping**
- `Alt+Shift+Left` - Swap window to left
- `Alt+Shift+Down` - Swap window down
- `Alt+Shift+Up` - Swap window up
- `Alt+Shift+Right` - Swap window to right

**Resizing**
- `Alt+Ctrl+Up` - Decrease window height
- `Alt+Ctrl+Down` - Increase window height
- `Alt+Ctrl+Left` - Decrease window width
- `Alt+Ctrl+Right` - Increase window width

**Splitting**
- `<leader>\` - Vertical split
- `<leader>-` - Horizontal split

### Buffer Navigation

**Quick Jump (matches bufferline numbers)**
- `Alt+1` - Jump to buffer 1 (first buffer)
- `Alt+2` - Jump to buffer 2
- `Alt+3` - Jump to buffer 3
- `Alt+4` through `Alt+9` - Jump to buffers 4-9

**Sequential Navigation**
- `Shift+l` - Next buffer
- `Shift+h` - Previous buffer

**Buffer Management**
- `<leader>c` - Close/delete current buffer

### File Explorer

- `<leader>e` - Toggle NvimTree
- `<leader>o` - Focus NvimTree

### Terminal

- `<leader>t` - Toggle terminal
- `<leader>cc` - Open Claude Code CLI in vertical terminal
- `Ctrl+\` - Toggle terminal (alternative)
- `Esc` (in terminal) - Exit terminal insert mode

### Telescope (Fuzzy Finder)

**Main Commands**
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>fb` - Browse buffers
- `<leader>fh` - Help tags
- `<leader>fp` - Recent files
- `<leader>fc` - Fuzzy find in current buffer

**Inside Telescope**
- `Ctrl+j` - Move to next result
- `Ctrl+k` - Move to previous result

### LSP (Language Server)

**Navigation**
- `gd` - Go to definition
- `gr` - Show references
- `K` - Show hover documentation

**Actions**
- `<leader>rn` - Rename symbol
- `<leader>ca` - Code actions
- `<leader>lf` - Format buffer

**Diagnostics**
- `<leader>ld` - Open diagnostic float
- `[d` - Go to previous diagnostic
- `]d` - Go to next diagnostic
- `<leader>xx` - Toggle Trouble
- `<leader>xw` - Workspace diagnostics
- `<leader>xd` - Document diagnostics

### Git Operations

- `<leader>gs` - Git status (Fugitive)
- `<leader>gj` - Next hunk
- `<leader>gk` - Previous hunk
- `<leader>gl` - Blame line
- `<leader>gp` - Preview hunk
- `<leader>gr` - Reset hunk
- `<leader>gR` - Reset buffer
- `<leader>gu` - Undo stage hunk
- `<leader>gd` - Diff this

### AI / Copilot

**Inline Suggestions**
- `Alt+l` - Accept suggestion
- `Alt+w` - Accept word
- `Alt+j` - Accept line (conflicts with move line down - may need adjustment)
- `Alt+]` - Next suggestion
- `Alt+[` - Previous suggestion
- `Ctrl+]` - Dismiss suggestion
- `Alt+Enter` - Open Copilot panel

**CopilotChat Commands**
- `<leader>ai` - Toggle Copilot Chat
- `<leader>ae` - Explain selected code (visual mode)
- `<leader>ar` - Review selected code (visual mode)
- `<leader>af` - Fix selected code (visual mode)
- `<leader>ao` - Optimize selected code (visual mode)
- `<leader>ad` - Generate docs (visual mode)
- `<leader>at` - Generate tests (visual mode)
- `<leader>ac` - Generate commit message

**Inside CopilotChat Window**
- `q` - Close (normal mode)
- `Ctrl+c` - Close (insert mode)
- `Ctrl+r` - Reset chat
- `Enter` - Submit prompt (normal mode)
- `Ctrl+s` - Submit prompt (insert mode)
- `Ctrl+y` - Accept diff
- `gy` - Yank diff
- `gd` - Show diff
- `gp` - Show system prompt
- `gs` - Show user selection

### Other Keybindings

**General**
- `<Esc>` - Clear search highlighting
- `<` - Outdent (visual mode, stays in visual)
- `>` - Indent (visual mode, stays in visual)

**Completion Menu (nvim-cmp)**
- `Ctrl+p` - Previous item
- `Ctrl+n` - Next item
- `Ctrl+Space` - Trigger completion
- `Ctrl+e` - Abort completion
- `Enter` - Confirm selection
- `Tab` - Next item (if visible)
- `Shift+Tab` - Previous item (if visible)

**Treesitter Text Objects**
- `af/if` - Around/inside function
- `ac/ic` - Around/inside class
- `aa/ia` - Around/inside parameter
- `]f/[f` - Next/previous function start
- `]c/[c` - Next/previous class start
- `]F/[F` - Next/previous function end
- `]C/[C` - Next/previous class end

**Treesitter Selection**
- `Enter` - Init/expand selection scope
- `Tab` - Expand node selection
- `Shift+Tab` - Shrink node selection

---

## Hyprland (OS Window Manager)

**Window Focus**
- `Super+Left/Down/Up/Right` - Move focus between windows
- `Super+h/j/k/l` - Alternative (vim-style)
- `Super+Tab` - Cycle to next window

**Window Swapping**
- `Super+Shift+Left/Down/Up/Right` - Swap window positions
- `Super+Shift+h/j/k/l` - Alternative (vim-style)

**Window Resizing**
- `Super+Ctrl+Left/Down/Up/Right` - Resize active window
- `Super+Ctrl+h/j/k/l` - Alternative (vim-style)

**Window Management**
- `Super+Q` - Kill active window
- `Super+Shift+F` - Toggle floating
- `Super+Ctrl+F` - Toggle fullscreen
- `Super+M` - Minimize (special workspace)

**Workspaces**
- `Super+1-0` - Switch to workspace 1-10 (primary monitor)
- `Super+Ctrl+1-0` - Switch to workspace 11-20 (secondary monitor)
- `Super+Alt+1-0` - Switch to workspace 21-30 (tertiary monitor)
- `Super+Shift+1-0` - Move window to workspace 1-10

**Applications**
- `Super+Enter` - Terminal (kitty)
- `Super+F` - File manager (yazi)
- `Super+B` - Browser (Chrome)
- `Super+D` - App launcher (rofi)
- `Super+Escape` - Lock screen

**Screenshots and Recording**
- `Super+Shift+S` - Screenshot to clipboard
- `Super+E` - Screenshot and edit
- `Super+Shift+R` - Record screen (GIF)
- `Super+R` - Record screen (MP4)

**Clipboard Management**
- `Super+V` - Clipboard to type
- `Super+Shift+V` - Clipboard to wlcopy
- `Super+X` - Delete clipboard item
- `Super+Shift+X` - Clear clipboard

---

## Navigation Pattern Consistency

### Modifier Hierarchy

```
Level          │ OS (Hyprland)         │ App (Neovim)
───────────────┼───────────────────────┼──────────────────────
Focus/Switch   │ Super + arrows        │ Alt + arrows
Swap           │ Super + Shift + ←↑↓→  │ Alt + Shift + ←↑↓→
Resize         │ Super + Ctrl + ←↑↓→   │ Alt + Ctrl + ←↑↓→
```

### Neovim Navigation Levels

```
Level          │ Modifier       │ Left/Right        │ Up/Down
───────────────┼────────────────┼───────────────────┼──────────────────
Char movement  │ None           │ ← → (h/l)         │ ↑ ↓ (k/j)
Word/Para jump │ Ctrl           │ ← → word          │ ↑ ↓ paragraph
Visual select  │ Shift          │ ← → select        │ ↑ ↓ select
Switch panes   │ Alt            │ ← → window        │ ↑ ↓ window
Swap panes     │ Alt+Shift      │ ← → move split    │ ↑ ↓ move split
Resize panes   │ Alt+Ctrl       │ ← → width         │ ↑ ↓ height
```

### Tab/Buffer Navigation Pattern

```
Application    │ Quick Jump         │ Sequential
───────────────┼────────────────────┼────────────────
Neovim buffers │ Alt+1-9            │ Shift+h/l
Hyprland       │ Super+1-0          │ Super+Tab
Kitty tabs     │ Alt+1-9            │ Alt+h/l
```

### Design Principles

1. **Arrow keys are primary** - Optimized for split keyboard layouts
2. **hjkl always available** - Kept as backup for muscle memory
3. **Consistent modifiers** - Same pattern across OS and applications
4. **Logical hierarchy** - Bare → Ctrl → Shift → Alt → combinations
5. **No conflicts** - All Vim commands (i, a, o, e, w, b, etc.) remain intact
6. **Modern conventions** - Matches browser/IDE patterns (Alt+numbers for tabs)

---

## Leader Key

**Leader** = `Space`

All `<leader>` bindings use the space bar as the leader key.

---

## Notes

- **Bufferline** displays ordinal numbers (1-9) matching `Alt+number` keybindings
- **Vi mode** enabled in Fish shell with arrow key support
- **Yazi** file manager supports arrow navigation by default
- **All programs** (Neovim, Fish, Yazi, Hyprland) use consistent arrow-based navigation
- Keybindings work in **both normal and insert mode** where applicable (Ctrl+arrows for jumps)
