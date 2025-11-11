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

      opener = {
        edit = [
          { run = ''nvim "$@"''; block = true; for = "unix"; }
        ];
        text = [
          { run = ''nvim "$@"''; block = true; for = "unix"; }
        ];
      };

      open = {
        rules = [
          # General text files
          { mime = "text/*"; use = "edit"; }
          { mime = "inode/x-empty"; use = "edit"; }

          # C/C++/C#/Objective-C
          { mime = "text/x-c"; use = "edit"; }
          { mime = "text/x-c++"; use = "edit"; }
          { mime = "text/x-csrc"; use = "edit"; }
          { mime = "text/x-chdr"; use = "edit"; }
          { mime = "text/x-csharp"; use = "edit"; }
          { mime = "text/x-objcsrc"; use = "edit"; }

          # Python
          { mime = "text/x-python"; use = "edit"; }
          { mime = "text/x-python3"; use = "edit"; }
          { mime = "application/x-python"; use = "edit"; }

          # JavaScript/TypeScript/Web
          { mime = "text/javascript"; use = "edit"; }
          { mime = "application/javascript"; use = "edit"; }
          { mime = "application/x-javascript"; use = "edit"; }
          { mime = "text/x-typescript"; use = "edit"; }
          { mime = "application/typescript"; use = "edit"; }
          { mime = "text/html"; use = "edit"; }
          { mime = "text/css"; use = "edit"; }
          { mime = "application/json"; use = "edit"; }
          { mime = "application/xml"; use = "edit"; }
          { mime = "text/xml"; use = "edit"; }

          # Rust
          { mime = "text/x-rust"; use = "edit"; }

          # Go
          { mime = "text/x-go"; use = "edit"; }

          # Java/Kotlin/Scala
          { mime = "text/x-java"; use = "edit"; }
          { mime = "text/x-kotlin"; use = "edit"; }
          { mime = "text/x-scala"; use = "edit"; }

          # Ruby
          { mime = "text/x-ruby"; use = "edit"; }
          { mime = "application/x-ruby"; use = "edit"; }

          # PHP
          { mime = "text/x-php"; use = "edit"; }
          { mime = "application/x-php"; use = "edit"; }

          # Shell scripts
          { mime = "text/x-shellscript"; use = "edit"; }
          { mime = "application/x-shellscript"; use = "edit"; }
          { mime = "text/x-sh"; use = "edit"; }
          { mime = "application/x-sh"; use = "edit"; }

          # Perl
          { mime = "text/x-perl"; use = "edit"; }
          { mime = "application/x-perl"; use = "edit"; }

          # Haskell
          { mime = "text/x-haskell"; use = "edit"; }

          # Lisp/Scheme/Clojure
          { mime = "text/x-lisp"; use = "edit"; }
          { mime = "text/x-scheme"; use = "edit"; }
          { mime = "text/x-clojure"; use = "edit"; }

          # Erlang/Elixir
          { mime = "text/x-erlang"; use = "edit"; }
          { mime = "text/x-elixir"; use = "edit"; }

          # OCaml/F#
          { mime = "text/x-ocaml"; use = "edit"; }
          { mime = "text/x-fsharp"; use = "edit"; }

          # Lua
          { mime = "text/x-lua"; use = "edit"; }

          # R
          { mime = "text/x-r"; use = "edit"; }

          # Julia
          { mime = "text/x-julia"; use = "edit"; }

          # Swift
          { mime = "text/x-swift"; use = "edit"; }

          # Dart
          { mime = "text/x-dart"; use = "edit"; }

          # Nim
          { mime = "text/x-nim"; use = "edit"; }

          # Zig
          { mime = "text/x-zig"; use = "edit"; }

          # Crystal
          { mime = "text/x-crystal"; use = "edit"; }

          # D
          { mime = "text/x-d"; use = "edit"; }

          # Fortran
          { mime = "text/x-fortran"; use = "edit"; }

          # Pascal
          { mime = "text/x-pascal"; use = "edit"; }

          # Assembly
          { mime = "text/x-asm"; use = "edit"; }

          # VHDL/Verilog
          { mime = "text/x-vhdl"; use = "edit"; }
          { mime = "text/x-verilog"; use = "edit"; }

          # SQL
          { mime = "text/x-sql"; use = "edit"; }
          { mime = "application/sql"; use = "edit"; }

          # Markup languages
          { mime = "text/markdown"; use = "edit"; }
          { mime = "text/x-markdown"; use = "edit"; }
          { mime = "text/x-tex"; use = "edit"; }
          { mime = "text/x-latex"; use = "edit"; }

          # Config files
          { mime = "text/x-yaml"; use = "edit"; }
          { mime = "application/x-yaml"; use = "edit"; }
          { mime = "text/x-toml"; use = "edit"; }
          { mime = "application/toml"; use = "edit"; }
          { mime = "text/x-ini"; use = "edit"; }
          { mime = "text/x-makefile"; use = "edit"; }
          { mime = "text/x-cmake"; use = "edit"; }
          { mime = "text/x-dockerfile"; use = "edit"; }

          # Nix
          { mime = "text/x-nix"; use = "edit"; }

          # Solidity (Ethereum smart contracts)
          { mime = "text/x-solidity"; use = "edit"; }

          # Git
          { mime = "text/x-diff"; use = "edit"; }
          { mime = "text/x-patch"; use = "edit"; }

          # Catch-all for any remaining programming files
          { name = "*.*"; use = "edit"; }
        ];
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
