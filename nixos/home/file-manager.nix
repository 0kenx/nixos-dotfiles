{inputs, username, host, pkgs, ...}: {
  # Install Nemo and Yazi file managers
  home.packages = with pkgs; [
    # Nemo file manager (Cinnamon's fork of Nautilus)
    nemo
    nemo-fileroller  # Archive support

    # Yazi - modern terminal file manager
    yazi

    # Supporting packages
    file-roller # Archive manager
    ffmpegthumbnailer # Video thumbnails
    poppler # PDF preview
    fd # Better find for yazi
    ripgrep # Better grep for yazi
    fzf # Fuzzy finder for yazi
    zoxide # Smarter cd for yazi
    # Note: ueberzugpp removed due to CUDA build issues - Yazi will still work great
  ];

  # Configure Yazi
  programs.yazi = {
    enable = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
    enableZshIntegration = true;

    settings = {
      manager = {
        show_hidden = true;
        sort_by = "natural";
        sort_dir_first = true;
        linemode = "size";
        show_symlink = true;
      };

      preview = {
        tab_size = 2;
        max_width = 600;
        max_height = 900;
      };
    };

    # Yazi keymaps
    keymap = {
      manager.prepend_keymap = [
        { on = [ "l" ]; run = "plugin --sync smart-enter"; desc = "Enter directory or open file"; }
        { on = [ "h" ]; run = "leave"; desc = "Go to parent directory"; }
        { on = [ "q" ]; run = "quit"; desc = "Quit"; }
        { on = [ "<Esc>" ]; run = "escape"; desc = "Cancel input"; }
        { on = [ "<C-q>" ]; run = "close"; desc = "Close tab"; }
      ];
    };
  };

  # Configure Nemo
  dconf.settings = {
    "org/nemo/preferences" = {
      show-hidden-files = true;
      show-location-entry = true;
      default-folder-viewer = "list-view";
      date-format = "iso";
      quick-renames-with-pause-in-between = true;
    };

    "org/nemo/window-state" = {
      sidebar-width = 200;
      start-with-sidebar = true;
    };

    "org/nemo/list-view" = {
      default-visible-columns = ["name" "size" "type" "date_modified"];
      default-column-order = ["name" "size" "type" "date_modified" "date_created"];
    };
  };

  # Configure file associations - use yazi (via terminal) as default for directories
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "inode/directory" = ["yazi.desktop" "nemo.desktop"];
    };
  };

  # Create a desktop entry for yazi in terminal
  xdg.desktopEntries.yazi = {
    name = "Yazi File Manager";
    genericName = "File Manager";
    comment = "Blazing fast terminal file manager";
    exec = "kitty yazi %u";
    icon = "utilities-terminal";
    terminal = false;
    categories = ["System" "FileTools" "FileManager"];
    mimeType = ["inode/directory"];
  };
}
