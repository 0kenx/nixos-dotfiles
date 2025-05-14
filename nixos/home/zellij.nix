{inputs, username, host, ...}: {
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-macchiato";
      
      # Keep all default plugins enabled
      plugins = [
        { path = "tab-bar"; }
        { path = "status-bar"; }
        { path = "strider"; }
        { path = "compact-bar"; }
      ];
      
      keybinds = {
        normal = {
          "Alt 1" = { GoToTab = 1; SwitchToMode = "Normal"; };
          "Alt 2" = { GoToTab = 2; SwitchToMode = "Normal"; };
          "Alt 3" = { GoToTab = 3; SwitchToMode = "Normal"; };
          "Alt 4" = { GoToTab = 4; SwitchToMode = "Normal"; };
          "Alt 5" = { GoToTab = 5; SwitchToMode = "Normal"; };
          "Alt 6" = { GoToTab = 6; SwitchToMode = "Normal"; };
          "Alt 7" = { GoToTab = 7; SwitchToMode = "Normal"; };
          "Alt 8" = { GoToTab = 8; SwitchToMode = "Normal"; };
          "Alt 9" = { GoToTab = 9; SwitchToMode = "Normal"; };
          "Alt 0" = "ToggleTab";
          "Alt x" = "CloseFocus";
          "Alt X" = "CloseTab";
          "Alt N" = "NewTab";
        };
        locked = {
          "Ctrl g" = { SwitchToMode = "Normal"; };
        };
        resize = {
          "Ctrl n" = { SwitchToMode = "Normal"; };
          "h" = { Resize = "Increase Left"; };
          "j" = { Resize = "Increase Down"; };
          "k" = { Resize = "Increase Up"; };
          "l" = { Resize = "Increase Right"; };
          "H" = { Resize = "Decrease Left"; };
          "J" = { Resize = "Decrease Down"; };
          "K" = { Resize = "Decrease Up"; };
          "L" = { Resize = "Decrease Right"; };
          "=" = { Resize = "Increase"; };
          "+" = { Resize = "Increase"; };
          "-" = { Resize = "Decrease"; };
          "Left" = { Resize = "Increase Left"; };
          "Down" = { Resize = "Increase Down"; };
          "Up" = { Resize = "Increase Up"; };
          "Right" = { Resize = "Increase Right"; };
        };
        pane = {
          "Ctrl p" = { SwitchToMode = "Normal"; };
          "h" = { MoveFocus = "Left"; };
          "l" = { MoveFocus = "Right"; };
          "j" = { MoveFocus = "Down"; };
          "k" = { MoveFocus = "Up"; };
          "p" = "SwitchFocus";
          "n" = { NewPane = null; SwitchToMode = "Normal"; };
          "d" = { NewPane = "Down"; SwitchToMode = "Normal"; };
          "r" = { NewPane = "Right"; SwitchToMode = "Normal"; };
          "x" = { CloseFocus = null; SwitchToMode = "Normal"; };
          "f" = { ToggleFocusFullscreen = null; SwitchToMode = "Normal"; };
          "z" = { TogglePaneFrames = null; SwitchToMode = "Normal"; };
          "w" = { ToggleFloatingPanes = null; SwitchToMode = "Normal"; };
          "e" = { TogglePaneEmbedOrFloating = null; SwitchToMode = "Normal"; };
          "c" = { SwitchToMode = "RenamePane"; PaneNameInput = 0; };
          "Left" = { MoveFocus = "Left"; };
          "Right" = { MoveFocus = "Right"; };
          "Down" = { MoveFocus = "Down"; };
          "Up" = { MoveFocus = "Up"; };
        };
        move = {
          "Ctrl h" = { SwitchToMode = "Normal"; };
          "n" = "MovePane";
          "h" = { MovePane = "Left"; };
          "j" = { MovePane = "Down"; };
          "k" = { MovePane = "Up"; };
          "l" = { MovePane = "Right"; };
          "Tab" = "MovePane";
          "Left" = { MovePane = "Left"; };
          "Down" = { MovePane = "Down"; };
          "Up" = { MovePane = "Up"; };
          "Right" = { MovePane = "Right"; };
        };
        tab = {
          "Ctrl t" = { SwitchToMode = "Normal"; };
          "r" = { SwitchToMode = "RenameTab"; TabNameInput = 0; };
          "h" = "GoToPreviousTab";
          "l" = "GoToNextTab";
          "n" = { NewTab = null; SwitchToMode = "Normal"; };
          "x" = { CloseTab = null; SwitchToMode = "Normal"; };
          "s" = { ToggleActiveSyncTab = null; SwitchToMode = "Normal"; };
          "1" = { GoToTab = 1; SwitchToMode = "Normal"; };
          "2" = { GoToTab = 2; SwitchToMode = "Normal"; };
          "3" = { GoToTab = 3; SwitchToMode = "Normal"; };
          "4" = { GoToTab = 4; SwitchToMode = "Normal"; };
          "5" = { GoToTab = 5; SwitchToMode = "Normal"; };
          "6" = { GoToTab = 6; SwitchToMode = "Normal"; };
          "7" = { GoToTab = 7; SwitchToMode = "Normal"; };
          "8" = { GoToTab = 8; SwitchToMode = "Normal"; };
          "9" = { GoToTab = 9; SwitchToMode = "Normal"; };
          "Tab" = "ToggleTab";
          "Left" = "GoToPreviousTab";
          "Right" = "GoToNextTab";
          "Up" = "GoToPreviousTab";
          "Down" = "GoToNextTab";
          "j" = "GoToNextTab";
          "k" = "GoToPreviousTab";
        };
        scroll = {
          "Ctrl s" = { SwitchToMode = "Normal"; };
          "e" = { EditScrollback = null; SwitchToMode = "Normal"; };
          "s" = { SwitchToMode = "EnterSearch"; SearchInput = 0; };
          "Ctrl c" = { ScrollToBottom = null; SwitchToMode = "Normal"; };
          "j" = "ScrollDown";
          "k" = "ScrollUp";
          "Ctrl f" = "PageScrollDown";
          "Ctrl b" = "PageScrollUp";
          "d" = "HalfPageScrollDown";
          "u" = "HalfPageScrollUp";
          "Down" = "ScrollDown";
          "Up" = "ScrollUp";
          "PageDown" = "PageScrollDown";
          "PageUp" = "PageScrollUp";
          "Right" = "PageScrollDown";
          "Left" = "PageScrollUp";
          "h" = "PageScrollUp";
          "l" = "PageScrollDown";
        };
        search = {
          "Ctrl s" = { SwitchToMode = "Normal"; };
          "Ctrl c" = { ScrollToBottom = null; SwitchToMode = "Normal"; };
          "j" = "ScrollDown";
          "k" = "ScrollUp";
          "Ctrl f" = "PageScrollDown";
          "Ctrl b" = "PageScrollUp";
          "d" = "HalfPageScrollDown";
          "u" = "HalfPageScrollUp";
          "n" = { Search = "down"; };
          "p" = { Search = "up"; };
          "c" = { SearchToggleOption = "CaseSensitivity"; };
          "w" = { SearchToggleOption = "Wrap"; };
          "o" = { SearchToggleOption = "WholeWord"; };
          "Down" = "ScrollDown";
          "Up" = "ScrollUp";
          "PageDown" = "PageScrollDown";
          "PageUp" = "PageScrollUp";
          "Right" = "PageScrollDown";
          "Left" = "PageScrollUp";
          "h" = "PageScrollUp";
          "l" = "PageScrollDown";
        };
        entersearch = {
          "Ctrl c" = { SwitchToMode = "Scroll"; };
          "Esc" = { SwitchToMode = "Scroll"; };
          "Enter" = { SwitchToMode = "Search"; };
        };
        renametab = {
          "Ctrl c" = { SwitchToMode = "Normal"; };
          "Esc" = { UndoRenameTab = null; SwitchToMode = "Tab"; };
        };
        renamepane = {
          "Ctrl c" = { SwitchToMode = "Normal"; };
          "Esc" = { UndoRenamePane = null; SwitchToMode = "Pane"; };
        };
        session = {
          "Ctrl o" = { SwitchToMode = "Normal"; };
          "Ctrl s" = { SwitchToMode = "Scroll"; };
          "d" = "Detach";
        };
        tmux = {
          "[" = { SwitchToMode = "Scroll"; };
          "Ctrl b" = { Write = 2; SwitchToMode = "Normal"; };
          "\"" = { NewPane = "Down"; SwitchToMode = "Normal"; };
          "%" = { NewPane = "Right"; SwitchToMode = "Normal"; };
          "z" = { ToggleFocusFullscreen = null; SwitchToMode = "Normal"; };
          "c" = { NewTab = null; SwitchToMode = "Normal"; };
          "," = { SwitchToMode = "RenameTab"; };
          "p" = { GoToPreviousTab = null; SwitchToMode = "Normal"; };
          "n" = { GoToNextTab = null; SwitchToMode = "Normal"; };
          "Left" = { MoveFocus = "Left"; SwitchToMode = "Normal"; };
          "Right" = { MoveFocus = "Right"; SwitchToMode = "Normal"; };
          "Down" = { MoveFocus = "Down"; SwitchToMode = "Normal"; };
          "Up" = { MoveFocus = "Up"; SwitchToMode = "Normal"; };
          "h" = { MoveFocus = "Left"; SwitchToMode = "Normal"; };
          "l" = { MoveFocus = "Right"; SwitchToMode = "Normal"; };
          "j" = { MoveFocus = "Down"; SwitchToMode = "Normal"; };
          "k" = { MoveFocus = "Up"; SwitchToMode = "Normal"; };
          "o" = "FocusNextPane";
          "d" = "Detach";
        };
        shared_except = {
          locked = {
            "Ctrl g" = { SwitchToMode = "Locked"; };
            "Ctrl q" = "Quit";
            "Alt n" = "NewPane";
            "Alt h" = { MoveFocusOrTab = "Left"; };
            "Alt l" = { MoveFocusOrTab = "Right"; };
            "Alt j" = { MoveFocus = "Down"; };
            "Alt k" = { MoveFocus = "Up"; };
            "Alt =" = { Resize = "Increase"; };
            "Alt +" = { Resize = "Increase"; };
            "Alt -" = { Resize = "Decrease"; };
            "Alt Left" = { MoveFocusOrTab = "Left"; };
            "Alt Right" = { MoveFocusOrTab = "Right"; };
            "Alt Down" = { MoveFocus = "Down"; };
            "Alt Up" = { MoveFocus = "Up"; };
          };
          normal = {
            locked = {
              "Enter" = { SwitchToMode = "Normal"; };
              "Esc" = { SwitchToMode = "Normal"; };
            };
          };
          pane = {
            locked = {
              "Ctrl p" = { SwitchToMode = "Pane"; };
            };
          };
          resize = {
            locked = {
              "Ctrl n" = { SwitchToMode = "Resize"; };
            };
          };
          scroll = {
            locked = {
              "Ctrl s" = { SwitchToMode = "Scroll"; };
            };
          };
          session = {
            locked = {
              "Ctrl o" = { SwitchToMode = "Session"; };
            };
          };
          tab = {
            locked = {
              "Ctrl t" = { SwitchToMode = "Tab"; };
            };
          };
          move = {
            locked = {
              "Ctrl h" = { SwitchToMode = "Move"; };
            };
          };
          tmux = {
            locked = {
              "Ctrl b" = { SwitchToMode = "Tmux"; };
            };
          };
        };
      };
    };
    
    # Theme is already set in settings above
    # theme = "catppuccin-macchiato";
  };
  
  # Instead of referencing the external file directly, we'll define the theme inline
  xdg.configFile."zellij/themes/catppuccin.kdl".text = ''
themes {
    catppuccin-frappe {
        fg 198 208 245
        bg 98 104 128
        black 41 44 60
        red 231 130 132
        green 166 209 137
        yellow 229 200 144
        blue 140 170 238
        magenta 244 184 228
        cyan 153 209 219
        white 198 208 245
        orange 239 159 118
    }
    catppuccin-latte {
        fg 172 176 190
        bg 172 176 190
        black 76 79 105
        red 210 15 57
        green 64 160 43
        yellow 223 142 29
        blue 30 102 245
        magenta 234 118 203
        cyan 4 165 229
        white 220 224 232
        orange 254 100 11
    }
    catppuccin-macchiato {
        fg 202 211 245
        bg 91 96 120
        black 30 32 48
        red 237 135 150
        green 166 218 149
        yellow 238 212 159
        blue 138 173 244
        magenta 245 189 230
        cyan 145 215 227
        white 202 211 245
        orange 245 169 127
    }
    catppuccin-mocha {
        fg 205 214 244
        bg 88 91 112
        black 24 24 37
        red 243 139 168
        green 166 227 161
        yellow 249 226 175
        blue 137 180 250
        magenta 245 194 231
        cyan 137 220 235
        white 205 214 244
        orange 250 179 135
    }
}
  '';
}