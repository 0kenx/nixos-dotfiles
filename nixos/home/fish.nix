{inputs, username, host, pkgs, ...}: {
  # Install packages required by fish functions
  home.packages = with pkgs; [
    # For fish_greeting
    figlet

    # For file and dir previews
    fd
    fzf
    bat
    lsd
    chafa
    ouch

    # For terminal utilities
    playerctl
  ];

  programs.fish = {
    enable = true;

    # Fish shell abbreviations (expanded when you press space)
    shellAbbrs = {
      # sudo bang-bang
      "sudo!!" = "sudo !!";

      # ls related
      ll = "lsd -Al";
      la = "lsd -A";
      "l." = "ls -d .* --color=auto";
      count = "find . -type f | wc -l";

      # sys related
      rm = "rmtrash";
      rmdir = "rmdirtrash";
      "ch+x" = "sudo chmod +x";
      "cha+x" = "sudo chmod a+x";
      untar = "tar -zxvf";
      wget = "wget -c";
      "cd.." = "cd ..";
      ".." = "cd ./..";
      "..." = "cd ../../";
      "..2" = "cd ../../";
      "...." = "cd ../../../";
      "..3" = "cd ../../../";
      "....." = "cd ../../../../";
      "..4" = "cd ../../../../";
      "..5" = "cd ../../../../..";
      "..6" = "cd ../../../../../..";
      "..7" = "cd ../../../../../../..";
      "..8" = "cd ../../../../../../../..";
      "..9" = "cd ../../../../../../../../..";
      h = "history";
      hg = "history | grep";
      now = "date +\"%T\"";
      nowtime = "date +\"%T\"";
      nowdate = "date +\"%d-%m-%Y\"";
      ping = "ping -c 5";
      #gfw = "proxychains4 !!";
      ports = "netstat -tulanp";
      meminfo = "free -m -l -t";
      #diff = "colordiff";
      p = "parallel";
      pp = "parallel --pipe -k";
      vifm = "vifmrun";

      # git abbreviations
      ga = "git add";
      gaa = "git add -A";
      gap = "git apply";
      gapt = "git apply --3way";
      gb = "git branch";
      gba = "git branch -a";
      gc = "git commit -s";
      gcb = "git checkout -b";
      gcount = "git shortlog -sn";
      gcm = "git checkout main";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gcl = "git clone";
      gd = "git diff";
      gl = "git pull";
      glr = "git pull --rebase";
      glg = "git log --stat --max-count=5";
      glgg = "git log --graph --max-count=5";
      gm = "git merge";
      gmm = "git merge main";
      grh = "git reset HEAD";
      grhh = "git reset HEAD --hard";
      gss = "git status -s";
      gst = "git status";
      gsw = "git switch";
      gup = "git fetch && git rebase";

      # docker
      dcl = "docker container ls";

      # development environment initialization
      di = "devinit";
      dv = "devinfo";
    };

    # Lazy-loaded Fish shell functions using autoload pattern
    functions = {
      # Git functions
      current_branch = ''
        git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||'
      '';

      current_repository = ''
        git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||'
        git remote -v | cut -d':' -f 2
      '';

      gitclean = ''
        git fetch -p
        for branch in (git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '$2 == "[gone]" {sub("refs/heads/", "", $1); print $1}')
          git branch -D $branch
        end
      '';

      # Special git abbreviations that use functions
      gca = ''
        git commit -s -a -m $argv
      '';

      gcaa = ''
        git commit -s -a --amend --no-edit
      '';

      gp = ''
        git pull --rebase && git push
      '';

      gpp = ''
        git push
      '';

      gclean = ''
        echo "Cleaning merged branches..."
        git remote prune origin
        gitclean
      '';

      ggl = ''
        git pull origin (current_branch)
      '';

      ggp = ''
        git push -u origin (current_branch)
      '';

      ggpp = ''
        git pull origin (current_branch) && git push -u origin (current_branch)
      '';

      # Other functions
      mkcd = ''
        mkdir -p $argv[1]
        cd $argv[1]
      '';

      mcd = ''
        mkdir -p $argv && cd $argv[-1]
      '';

      cpv = ''
        rsync -ah --info=progress2 $argv
      '';

      proc = ''
        ps aux | head -n 1
        ps aux | grep $argv
      '';

      psmem = ''
        ps aux | head -n 1
        ps aux | sort -nr -k 4
      '';

      # Development environment initialization
      devinit = ''
        # Base path to templates
        set -l template_base "$HOME/git/nixos-dotfiles/user/projects"

        # Check if language argument is provided
        if test (count $argv) -eq 0
            echo "Usage: devinit <language>"
            echo ""
            echo "Available templates:"
            echo "  devinit rust      - Rust with Crane, cargo tools"
            echo "  devinit python    - Python 3.12 with uv"
            echo "  devinit solidity  - Solidity with Foundry"
            return 1
        end

        set -l language $argv[1]
        set -l template_dir ""

        # Determine template directory
        switch $language
            case rust
                set template_dir "$template_base/optimized-pre-config-rust"
            case python py
                set template_dir "$template_base/optimized-pre-config-python"
            case solidity sol
                set template_dir "$template_base/optimized-pre-config-solidity"
            case '*'
                echo "❌ Unknown language: $language"
                echo ""
                echo "Available templates: rust, python, solidity"
                return 1
        end

        # Check if template exists
        if not test -d "$template_dir"
            echo "❌ Template directory not found: $template_dir"
            return 1
        end

        # Check if current directory is empty (excluding hidden files)
        set -l visible_files (ls -A 2>/dev/null | grep -v '^\.' | wc -l)
        if test $visible_files -gt 0
            echo "⚠️  Current directory is not empty!"
            echo "Files will be copied from template. Continue? [y/N]"
            read -l confirm
            if test "$confirm" != "y" -a "$confirm" != "Y"
                echo "Cancelled."
                return 1
            end
        end

        # Copy template files
        echo "📦 Copying $language template..."
        cp -r "$template_dir"/. .

        if test $status -ne 0
            echo "❌ Failed to copy template files"
            return 1
        end

        echo "✓ Template files copied"

        # Initialize git if not already a git repo
        if not test -d .git
            echo "📝 Initializing git repository..."
            git init
            echo "✓ Git repository initialized"
        end

        # Add files to git so Nix flake can see them
        echo "📝 Adding files to git..."
        git add -A
        echo "✓ Files staged"

        # Run direnv allow if .envrc exists
        if test -f .envrc
            echo "🔧 Activating direnv..."
            direnv allow
            if test $status -eq 0
                echo "✓ Direnv activated"
            else
                echo "⚠️  Direnv activation failed. Run 'direnv allow' manually."
            end
        end

        # Show next steps based on language
        echo ""
        echo "🎉 $language development environment initialized!"
        echo ""
        echo "Next steps:"

        switch $language
            case rust
                echo "  1. just build               # Build project"
                echo "  2. just test                # Run tests"
                echo "  3. just help                # See all commands"
            case python py
                echo "  1. just setup-project myapp # Create src/ structure"
                echo "  2. just venv                # Create virtual environment"
                echo "  3. source .venv/bin/activate"
                echo "  4. just install             # Install dependencies"
                echo "  5. just test                # Run tests"
                echo "  6. just help                # See all commands"
            case solidity sol
                echo "  1. just init                # Initialize Foundry project"
                echo "  2. just build               # Build contracts"
                echo "  3. just test                # Run tests"
                echo "  4. just help                # See all commands"
        end

        echo ""
        echo "📖 Read README.md for detailed documentation"
      '';

      devinfo = ''
        set -l has_info false

        echo "🔍 Development Environment Info"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""

        # Check for Rust
        if test -f Cargo.toml
            echo "📦 Language: Rust"
            if type -q cargo
                echo "   Version: "(cargo --version 2>/dev/null | string split ' ')[2]
            end
            if test -f rust-toolchain.toml
                echo "   Toolchain: Custom (see rust-toolchain.toml)"
            end
            set has_info true
        end

        # Check for Python
        if test -f pyproject.toml; or test -f setup.py; or test -f requirements.txt
            echo "📦 Language: Python"
            if type -q python
                echo "   Version: "(python --version 2>/dev/null | string split ' ')[2]
            end
            if test -f .python-version
                echo "   Expected: "(cat .python-version)
            end
            if test -d .venv
                echo "   Venv: ✓ (.venv/)"
            else
                echo "   Venv: ✗ (run 'just venv')"
            end
            set has_info true
        end

        # Check for Solidity
        if test -f foundry.toml
            echo "📦 Language: Solidity"
            if type -q forge
                echo "   Foundry: "(forge --version 2>/dev/null | head -n1)
            end
            if type -q solc
                echo "   Solc: "(solc --version 2>/dev/null | head -n1)
            end
            set has_info true
        end

        # Check for Node.js
        if test -f package.json
            echo "📦 Language: JavaScript/TypeScript"
            if type -q node
                echo "   Node: "(node --version)
            end
            if type -q npm
                echo "   npm: "(npm --version)
            end
            if test -d node_modules
                echo "   Packages: ✓ (node_modules/)"
            else
                echo "   Packages: ✗ (run 'npm install')"
            end
            set has_info true
        end

        # Check for Go
        if test -f go.mod
            echo "📦 Language: Go"
            if type -q go
                echo "   Version: "(go version | string split ' ')[2]
            end
            set has_info true
        end

        echo ""

        # Check for Nix flake
        if test -f flake.nix
            echo "❄️  Nix: flake.nix present"
            if test -f flake.lock
                echo "   Lock: ✓"
            else
                echo "   Lock: ✗ (run 'nix flake lock')"
            end
        end

        # Check for direnv
        if test -f .envrc
            echo "🔧 Direnv: .envrc present"
            if direnv status 2>/dev/null | grep -q "Found RC allowed true"
                echo "   Status: ✓ Activated"
            else
                echo "   Status: ✗ Not activated (run 'direnv allow')"
            end
        end

        # Check for justfile
        if test -f justfile; or test -f Justfile
            echo "⚙️  Just: Task runner available (run 'just help')"
        end

        # Check for git
        if test -d .git
            echo "📝 Git: Repository initialized"
            set -l branch (git branch --show-current 2>/dev/null)
            if test -n "$branch"
                echo "   Branch: $branch"
            end
            set -l status_output (git status --short 2>/dev/null)
            if test -n "$status_output"
                echo "   Status: Uncommitted changes"
            else
                echo "   Status: Clean"
            end
        end

        if not $has_info
            echo "ℹ️  No recognized development project in current directory"
            echo ""
            echo "Initialize a new project with:"
            echo "  devinit rust      - Rust project"
            echo "  devinit python    - Python project"
            echo "  devinit solidity  - Solidity project"
        end

        echo ""
      '';

      psmem10 = ''
        ps aux | head -n 1
        ps aux | sort -nr -k 4 | head -10
      '';

      pscpu = ''
        ps aux | head -n 1
        ps aux | sort -nr -k 3
      '';

      pscpu10 = ''
        ps aux | head -n 1
        ps aux | sort -nr -k 3 | head -10
      '';

      batt = ''
        upower -i /org/freedesktop/UPower/devices/battery_BAT0
      '';

      sr = ''
        sudo systemctl restart $argv
      '';

      path = ''
        echo -e $PATH | tr -s ":" "\n"
      '';

      extract = ''
        if test -f $argv[1]
          set filename (echo $argv[1] | tr '[:upper:]' '[:lower:]')
          switch $filename
            case '*.tar.bz2'
              tar xvjf $argv[1]
            case '*.tar.gz'
              tar xvzf $argv[1]
            case '*.tar.xz'
              tar Jxvf $argv[1]
            case '*.bz2'
              bunzip2 $argv[1]
            case '*.rar'
              rar x $argv[1]
            case '*.gz'
              gunzip $argv[1]
            case '*.xz'
              unxz $argv[1]
            case '*.tar'
              tar xvf $argv[1]
            case '*.tbz2'
              tar xvjf $argv[1]
            case '*.tgz'
              tar xvzf $argv[1]
            case '*.zip'
              unzip -d (echo $argv[1] | sed 's/\(.*\)\.zip/\1/') $argv[1]
            case '*.z'
              uncompress $argv[1]
            case '*.7z'
              7z x $argv[1]
            case '*'
              echo "don't know how to extract '$argv[1]'"
          end
        else
          echo "'$argv[1]' is not a valid file!"
        end
      '';

      weather = ''
        curl -s "wttr.in/$argv[1]?m1" | grep -vw "Follow"
      '';

      myip = ''
        curl ifconfig.me
      '';

      activate = ''
        source ~/.venv/$argv[1]/bin/activate.fish
      '';

      mark = ''
        set -gx $argv[1] (pwd)
      '';

      gdv = ''
        git diff -w $argv | view -
      '';

      alert = ''
        set -l status_face (test $status = 0 && echo terminal || echo error)
        set -l last_cmd (history | head -n1 | sed -e "s/^\\s*[0-9]\\+\\s*//;s/[;&|]\\s*alert\$//")
        notify-send --urgency=low -i $status_face $last_cmd
      '';

      hr = ''
        function _rh
          set cmd (history | grep "^\\s*$argv[1]\\s" | sed "s/^\\s*$argv[1]\\s*//")
          echo "Executing: $cmd"
          echo -n "Confirm? (y/N) "
          read confirm
          if test "$confirm" = "y" -o "$confirm" = "Y"
            eval $cmd
          else
            echo "Command not executed"
          end
        end
        _rh $argv
      '';

      # Complex sloc function
      sloc = ''
        set -l filter_exts "c|cpp|h|hpp|cmake|mk|bzl|py|ipynb|js|jsx|ts|css|htm|html|htmx|xhtml|go|java|hs|fut|sol|move|mo|rs|zig|sh|nix|tf|lua|yml|json|proto|gql|sql"
        set -l add_exts ""
        set -l excl_exts ""
        set -l only_exts ""
        set -l sort_by_count false
        set -l summary_only false

        # Parse arguments
        set -l options "a/add=+" "e/exclude=+" "o/only=+" "d/descending" "s/summary" "h/help"
        argparse $options -- $argv

        if set -q _flag_help
          echo "Usage: sloc [-a ext1,ext2] [-e ext1,ext2] [-o ext1,ext2] [-d] [-s] [-h]"
          echo "Count lines of code, excluding blank lines, bracket-only lines, and comments"
          echo ""
          echo "Options:"
          echo "  -a, --add ext1,ext2     Include additional file extensions"
          echo "  -e, --exclude ext1,ext2 Exclude specified file extensions"
          echo "  -o, --only ext1,ext2    Include ONLY the specified extensions (overrides -a and -e)"
          echo "  -d, --descending        Display results in descending order by line count"
          echo "  -s, --summary           Summary mode - only show totals by file type"
          echo "  -h, --help              Display this help message"
          echo ""
          echo "Default extensions: c cpp h hpp cmake mk bzl py ipynb js jsx ts css htm html htmx xhtml go java hs fut sol move mo rs zig sh nix tf lua yml json proto gql sql"
          return 0
        end

        # Process only_exts (overrides other extension options)
        if set -q _flag_only
          set filter_exts (string replace , "|" $_flag_only)
        else
          # Process additional extensions
          if set -q _flag_add
            set filter_exts "$filter_exts|"(string replace , "|" $_flag_add)
          end

          # Process excluded extensions
          if set -q _flag_exclude
            for ext in (string split , $_flag_exclude)
              set filter_exts (string replace -r "|$ext\$" "" $filter_exts)
              set filter_exts (string replace -r "^$ext|" "" $filter_exts)
              set filter_exts (string replace -r "|$ext|" "|" $filter_exts)
            end
          end
        end

        # Display included extensions
        set -l display_exts (string replace -a "|" ", " $filter_exts)
        echo "Included extensions: $display_exts"

        # Get file list based on git repo presence
        set -l files
        if git rev-parse --is-inside-work-tree 2>/dev/null
          # Include both tracked and untracked files (but respect .gitignore)
          for file in (git ls-files; git ls-files --others --exclude-standard)
            if string match -qr "\\.($filter_exts)\$" -- $file
              set -a files $file
            end
          end
        else
          for file in (find . -type f)
            if string match -qr "\\.($filter_exts)\$" -- $file
              set -a files $file
            end
          end
        end

        # Count lines function
        function count_lines
          cat $argv[1] 2>/dev/null | \
            grep -v "^[[:space:]]*\$" | \
            grep -v "^[[:space:]]*[{}\\\\[\\\\]()]*[[:space:]]*\$" | \
            grep -v "^[[:space:]]*//" | \
            grep -v "^[[:space:]]*--" | \
            grep -v "^[[:space:]]*#" | \
            grep -v "^[[:space:]]*'" | \
            wc -l
        end

        # Count total lines
        set -l total_sloc 0
        if test (count $files) -gt 0
          set total_sloc (cat $files 2>/dev/null | \
            grep -v "^[[:space:]]*\$" | \
            grep -v "^[[:space:]]*[{}\\\\[\\\\]()]*[[:space:]]*\$" | \
            grep -v "^[[:space:]]*//" | \
            grep -v "^[[:space:]]*--" | \
            grep -v "^[[:space:]]*#" | \
            grep -v "^[[:space:]]*'" | \
            wc -l)
        end

        # Print total SLOC header if in summary mode
        if set -q _flag_summary
          echo "Total SLOC: $total_sloc"
        end

        # Show detailed file listing if not in summary mode
        if not set -q _flag_summary
          # Build file data with counts
          set -l file_data

          for file in $files
            set -l count (count_lines $file)
            set -a file_data "$file:$count"
          end

          # Calculate max count length for alignment (minimum 6)
          set -l max_count 6
          # Also check total_sloc length
          if test (string length $total_sloc) -gt $max_count
            set max_count (string length $total_sloc)
          end
          for item in $file_data
            set -l count (string split -m1 ":" $item)[2]
            if test (string length $count) -gt $max_count
              set max_count (string length $count)
            end
          end

          # Check if descending mode (sort by line count)
          if set -q _flag_descending
            # Sort by line count (descending) - just print files without tree
            for item in (printf "%s\\n" $file_data | sort -t: -k2 -nr)
              set -l parts (string split -m1 ":" $item)
              set -l filepath $parts[1]
              set -l count $parts[2]
              printf "%"$max_count"d  %s\\n" $count $filepath
            end
          else
            # Sort by path (tree view)
            set file_data (printf "%s\\n" $file_data | sort)

            # Print total SLOC as root
            printf "%"$max_count"d  .\\n" $total_sloc

            # Track printed directories
            set -l printed_dirs

            for item in $file_data
              set -l parts (string split -m1 ":" $item)
              set -l filepath $parts[1]
              set -l count $parts[2]
              set -l dir (dirname $filepath)
              set -l filename (basename $filepath)

              # Calculate depth
              set -l depth 0
              if test "$dir" != "."
                set depth (string split "/" $dir | count)
              end

              # Print all parent directories that haven't been printed yet
              if test "$dir" != "."
                set -l dir_parts (string split "/" $dir)
                for d in (seq 1 (count $dir_parts))
                  set -l current_dir (string join "/" $dir_parts[1..$d])

                  if not contains $current_dir $printed_dirs
                    # Calculate directory total
                    set -l dir_total 0
                    for di in $file_data
                      set -l di_parts (string split -m1 ":" $di)
                      set -l di_path $di_parts[1]
                      set -l di_count $di_parts[2]
                      if string match -q "$current_dir/*" $di_path
                        set dir_total (math $dir_total + $di_count)
                      end
                    end

                    # Build indent
                    set -l dir_depth (math $d - 1)
                    set -l dir_indent ""
                    for i in (seq 1 $dir_depth)
                      set dir_indent "$dir_indent│   "
                    end

                    set -l dir_name (basename $current_dir)
                    printf "%"$max_count"d  %s├──%s/\\n" $dir_total $dir_indent $dir_name
                    set -a printed_dirs $current_dir
                  end
                end
              end

              # Print file with indent
              set -l file_indent ""
              for d in (seq 1 $depth)
                set file_indent "$file_indent│   "
              end

              printf "%"$max_count"d  %s├──%s\\n" $count $file_indent $filename
            end
          end
        end

        # Always show the summary by file type
        echo -e "\\nSummary by file type:"
        if test (count $files) -gt 0
          for ext in (printf "%s\\n" $files | sed -E 's/.*\\.([^.]+)$/\\1/' | sort | uniq)
            set -l ext_files
            for f in $files
              if string match -qr "\\.$ext\$" -- $f
                set -a ext_files $f
              end
            end
            set -l count (cat $ext_files 2>/dev/null | \
              grep -v "^[[:space:]]*\$" | \
              grep -v "^[[:space:]]*[{}\\\\[\\\\]()]*[[:space:]]*\$" | \
              grep -v "^[[:space:]]*//" | \
              grep -v "^[[:space:]]*--" | \
              grep -v "^[[:space:]]*#" | \
              grep -v "^[[:space:]]*'" | \
              wc -l)
            printf "%6d  .%s\\n" $count $ext
          end | begin
            if set -q _flag_descending
              sort -nr
            else
              sort -k2
            end
          end
        end
      '';

      # Migrated functions from ~/.config/fish/functions

      # NOTE: autostart function is removed since we're using systemd instead

      aichat_fish = ''
        set -l _old (commandline)
        if test -n $_old
            echo -n "⌛"
            commandline -f repaint
            commandline (aichat -e $_old)
        end
      '';

      archive-preview = ''
        set archive "$argv[1]"
        set supported_archive_formats tar.gz tar.bz2 tar.xz zip rar 7z

        for format in $supported_archive_formats
            if string match -q "application/$format" (file -b --mime-type "$archive")
                ouch list --tree --no "$archive"
                exit 0
            end
        end
      '';

      back-op = ''
        cd ..
        commandline -f repaint
      '';

      backtrack-op = ''
        cd -
        commandline -f repaint
      '';

      dir-preview = ''
        set dir "$argv[1]"
        lsd --tree --depth=1 --color=always --icon=always --icon-theme=fancy "$dir"
      '';

      fetch_music_player_data = ''
        playerctl -a metadata --format "{\"text\": \"{{artist}} - {{markup_escape(title)}}\", \"tooltip\": \"<i><span color='#a6da95'>{{playerName}}</span></i>: <b><span color='#f5a97f'>{{artist}}</span> - <span color='#c6a0f6'>{{markup_escape(title)}}</span></b>\", \"alt\": \"{{status}}\", \"class\": \"{{status}}\"}" -F
      '';

      file-preview = ''
        set file "$argv[1]"
        bat --color=always --style=numbers,header-filesize,grid --line-range=:15 --wrap=auto "$file"
      '';

      clear-op = ''
        clear
        commandline -f repaint
      '';

      list-op = ''
        ls
        commandline -f repaint
      '';

      fish_greeting = ''
        set_color blue
        echo " Distro:  NixOS"
        set_color white
        echo "󰅱 Langs:   Rust  Zig  Go  JS 󰛦 TS  Python  Lua  Wasm"
        set_color green
        echo " Shell:  󰈺 Fish"
        # clear
      '';

      fish_user_key_bindings = ''
        # Execute this once per mode that emacs bindings should be used in
        fish_default_key_bindings -M insert

        # Then execute the vi-bindings so they take precedence when there's a conflict.
        # Without --no-erase fish_vi_key_bindings will default to
        # resetting all bindings.
        # The argument specifies the initial mode (insert, "default" or visual).
        fish_vi_key_bindings --no-erase insert

        # Nullify fzf default keybindings
        bind \cT "" -M insert
        bind \cR "" -M insert

        bind \er fzf-history-widget -M insert
        bind \ef fzf-file-preview-widget -M insert
        bind \ec fzf-cd-preview-widget -M insert
        bind \ep fzf-ps-widget -M insert

        bind \e\f clear-op -M insert
        bind \eb back-op -M insert
        bind \eB backtrack-op -M insert
        bind \e/ list-op -M insert

        bind \ea aichat_fish -M insert
      '';

      fzf-cd-preview-widget = ''
        set selected_dir (fd --type d --hidden --no-ignore --exclude .git --exclude .direnv | fzf --height 40% --reverse --preview 'dir-preview {}' --preview-window=right:40%)

        if test -n "$selected_dir"
            cd "$selected_dir"
        end
        commandline -f repaint
      '';

      fzf-file-preview-widget = ''
        commandline -i (fd --hidden --no-ignore --exclude .git --exclude .direnv | fzf --height 40% --preview-window=right:40% --reverse --preview 'switch-preview {}')
        commandline -f repaint
      '';

      fzf-ps-widget = ''
        commandline -i (pgrep -a . | fzf --height 40%)
        commandline -f repaint
      '';

      image-preview = ''
        set image "$argv[1]"

        # Retrieve the current terminal dimensions and reduce them slightly to avoid boundary issues
        set term_width (math (tput cols) - 1)
        set term_height (math (tput lines) - 1)

        chafa "$image" --size="$term_width"x"$term_height"
      '';

      switch-preview = ''
        set path "$argv[1]"

        if test -f "$path"
            if test ! -s "$path"
                echo "File is empty"
            else
                archive-preview "$path"
                if string match -q "image/*" (file -b --mime-type "$path")
                    image-preview "$path"
                else
                    file-preview "$path"
                end
            end
        else if test -d "$path"
            dir-preview "$path"
        else
            echo "Preview unavailable"
        end
      '';

      tre = ''
        command tre "$argv" -e | less
      '';

      bluetooth_toggle = ''
        set bluetooth_status (rfkill list bluetooth | grep -i -o "Soft blocked: yes")
        set backup_file ~/.cache/airplane_backup

        if [ -z "$bluetooth_status" ]
            rfkill block bluetooth
        else
            rfkill unblock bluetooth
            if test -e $backup_file
                rm $backup_file
            end
        end
      '';

      wifi_toggle = ''
        set wifi_status (rfkill list wifi | grep -i -o "Soft blocked: yes")
        set backup_file ~/.cache/airplane_backup

        if [ -z "$wifi_status" ]
            rfkill block wifi
        else
            rfkill unblock wifi
            if test -e $backup_file
                rm $backup_file
            end
        end
      '';

      screenshot_to_clipboard = ''
        set screenshot_filename (echo "$HOME/Pictures/Screenshots/screenshot-$(date +"%Y-%m-%d--%H:%M:%S").png")
        grim -g (slurp) $screenshot_filename

        if [ -e $screenshot_filename ]
            cat $screenshot_filename | wl-copy --type image/png
            dunstify -i $screenshot_filename -r (cd ~/Pictures/Screenshots/ && ls -1 | wc -l) "Screenshots" "Screenshot was taken" -t 2000
        end
      '';

      dunst_pause = ''
        set COUNT_WAITING (dunstctl count waiting)
        set COUNT_DISPLAYED (dunstctl count displayed)
        set ENABLED "{ \"text\": \"󰂜\", \"tooltip\": \"notifications <span color='#a6da95'>on</span>\", \"class\": \"on\" }"
        set DISABLED "{ \"text\": \"󰪑\", \"tooltip\": \"notifications <span color='#ee99a0'>off</span>\", \"class\": \"off\" }"

        if [ $COUNT_DISPLAYED != 0 ]
            set ENABLED "{ \"text\": \"󰂚$COUNT_DISPLAYED\", \"tooltip\": \"$COUNT_DISPLAYED notifications\", \"class\": \"on\" }"
        end

        if [ $COUNT_WAITING != 0 ]
            set DISABLED "{ \"text\": \"󰂛$COUNT_WAITING\", \"tooltip\": \"(silent) $COUNT_WAITING notifications\", \"class\": \"off\" }"
        end

        if dunstctl is-paused | rg -q "false"
            echo $ENABLED
        else
            echo $DISABLED
        end
      '';

      wlogout_uniqe = ''
        if [ -z $(pidof wlogout) ]
            wlogout
        end
      '';

      record_screen_gif = ''
        set target_process wl-screenrec

        if pgrep $target_process >/dev/null
            killall -s SIGINT $target_process
        else
            set geometry (slurp)
            if not [ -z $geometry ]
                set record_name $(echo "recrod-$(date +"%Y-%m-%d--%H:%M:%S")")
                dunstify -i ~/.config/fish/icons/camera_gif_icon.png -r $(cd ~/Pictures/Records/ && ls -1 | wc -l) "Recording Started  (GIF)" -t 2000
                wl-screenrec -g "$geometry" -f "$HOME/Pictures/Records/$record_name.mp4" --encode-resolution 1920x1080
                ffmpeg -i "$HOME/Pictures/Records/$record_name.mp4" "$HOME/Pictures/Records/$record_name.gif"
                rm "$HOME/Pictures/Records/$record_name.mp4"
                wl-copy -t text/uri-list file://$HOME/Pictures/Records/$record_name.gif\n
                dunstify -i ~/.config/fish/icons/camera_gif_icon.png -r $(cd ~/Pictures/Records/ && ls -1 | wc -l) "Recording Stopped 󰙧 (GIF)" -t 2000
            end
        end
      '';

      record_screen_mp4 = ''
        set target_process wl-screenrec

        if pgrep $target_process >/dev/null
            killall -s SIGINT $target_process
        else
            set geometry (slurp)
            if not [ -z $geometry ]
                set record_name $(echo "record-$(date +"%Y-%m-%d--%H:%M:%S")")
                dunstify -i ~/.config/fish/icons/camera_mp4_icon.png -r $(cd ~/Videos/Records/ && ls -1 | wc -l) "Recording Started  (MP4)" -t 2000
                wl-screenrec -g "$geometry" -f "$HOME/Videos/Records/$record_name.mp4"
                wl-copy -t text/uri-list file://$HOME/Videos/Records/$record_name.mp4\n
                dunstify -i ~/.config/fish/icons/camera_mp4_icon.png -r $(cd ~/Videos/Records/ && ls -1 | wc -l) "Recording Stopped 󰙧 (MP4)" -t 2000
            end
        end
      '';

      screenshot_edit = ''
        set screenshot_filename (echo "$HOME/Pictures/Screenshots/screenshot-$(date +"%Y-%m-%d--%H:%M:%S").png")
        grim -g (slurp) $screenshot_filename

        if [ -e $screenshot_filename ]
            dunstify -i $screenshot_filename -r (cd ~/Pictures/Screenshots/ && ls -1 | wc -l) "Screenshots" "Screenshot was taken" -t 2000
            swappy -f $screenshot_filename -o $screenshot_filename
        end
      '';

      clipboard_to_type = ''
        if command -v cliphist >/dev/null
          cliphist list | rofi -dmenu | cliphist decode | wtype -
        end
      '';

      clipboard_to_wlcopy = ''
        if command -v cliphist >/dev/null
          cliphist list | rofi -dmenu | cliphist decode | wl-copy
        end
      '';

      clipboard_delete_item = ''
        if command -v cliphist >/dev/null
          cliphist list | rofi -dmenu | cliphist delete
        end
      '';

      clipboard_clear = ''
        if command -v cliphist >/dev/null
          cliphist wipe
        end
      '';

      bookmark_to_type = ''
        if command -v clipman >/dev/null
          cat ~/.config/clipman/url_bookmarks.txt | rofi -dmenu | wtype -
        end
      '';

      bookmark_add = ''
        if command -v clipman >/dev/null
          wl-paste | clipman store --no-persist
        end
      '';

      bookmark_delete = ''
        if command -v clipman >/dev/null
          clipman clear --all
        end
      '';

      airplane_mode_toggle = ''
        set backup_file ~/.cache/airplane_backup
        set airplane_mode_on false

        # Check if either WiFi or Bluetooth is blocked
        set wifi_blocked (rfkill list wifi | grep -i -o "Soft blocked: yes")
        set bluetooth_blocked (rfkill list bluetooth | grep -i -o "Soft blocked: yes")

        if [ -n "$wifi_blocked" ] || [ -n "$bluetooth_blocked" ]
            set airplane_mode_on true
        end

        if [ "$airplane_mode_on" = true ]
            # Airplane mode is ON, turn it OFF
            if test -e $backup_file
                # Restore previous state
                set backup_content (cat $backup_file)
                if echo $backup_content | grep -q "wifi=on"
                    rfkill unblock wifi
                end
                if echo $backup_content | grep -q "bluetooth=on"
                    rfkill unblock bluetooth
                end
                rm $backup_file
            else
                # No backup file, unblock everything
                rfkill unblock wifi
                rfkill unblock bluetooth
            end
        else
            # Airplane mode is OFF, turn it ON
            # Save current state
            set wifi_status (rfkill list wifi | grep -i -o "Soft blocked: no")
            set bluetooth_status (rfkill list bluetooth | grep -i -o "Soft blocked: no")

            echo -n "" > $backup_file
            if [ -n "$wifi_status" ]
                echo "wifi=on" >> $backup_file
            else
                echo "wifi=off" >> $backup_file
            end

            if [ -n "$bluetooth_status" ]
                echo "bluetooth=on" >> $backup_file
            else
                echo "bluetooth=off" >> $backup_file
            end

            # Block all
            rfkill block wifi
            rfkill block bluetooth
        end
      '';

      check_airplane_mode = ''
        set backup_file ~/.cache/airplane_backup
        set ENABLED "{ \"text\": \"󰀝\", \"tooltip\": \"airplane mode <span color='#a6da95'>on</span>\", \"class\": \"on\" }"
        set DISABLED "{ \"text\": \"󰀞\", \"tooltip\": \"airplane mode <span color='#ee99a0'>off</span>\", \"class\": \"off\" }"

        # Check if either WiFi or Bluetooth is blocked
        set wifi_blocked (rfkill list wifi | grep -i -o "Soft blocked: yes")
        set bluetooth_blocked (rfkill list bluetooth | grep -i -o "Soft blocked: yes")

        if [ -n "$wifi_blocked" ] && [ -n "$bluetooth_blocked" ]
            echo $ENABLED
        else
            echo $DISABLED
        end
      '';

      night_mode_toggle = ''
        set night_on (pgrep -c gammastep)

        if [ "$night_on" = "0" ]
            gammastep -l (geoclue2-agent) -t 6500:3500 -m wayland &
        else
            killall gammastep
        end
      '';

      check_night_mode = ''
        set night_on (pgrep -c gammastep)
        set ENABLED "{ \"text\": \"󰃝\", \"tooltip\": \"night light <span color='#a6da95'>on</span>\", \"class\": \"on\" }"
        set DISABLED "{ \"text\": \"󰃞\", \"tooltip\": \"night light <span color='#ee99a0'>off</span>\", \"class\": \"off\" }"

        if [ "$night_on" = "0" ]
            echo $DISABLED
        else
            echo $ENABLED
        end
      '';

      check_recording = ''
        set RECORDING "{ \"text\": \"󰻃\", \"tooltip\": \"recording in progress\", \"class\": \"recording\" }"
        echo $RECORDING
      '';

      check_geo_module = ''
        set ENABLED "{ \"text\": \"󰒊\", \"tooltip\": \"geoclue active\", \"class\": \"on\" }"
        echo $ENABLED
      '';

      check_webcam = ''
        set cam_in_use (lsmod | grep ^uvcvideo | awk '{print $3}')

        if [ "$cam_in_use" != "0" ]
            set WEBCAM_ON "{ \"text\": \"󰛐\", \"tooltip\": \"webcam in use\", \"class\": \"webcam-on\" }"
            echo $WEBCAM_ON
        else
            set WEBCAM_OFF ""
            echo $WEBCAM_OFF
        end
      '';
    };

    shellAliases = {
      # The basic aliases are better as shellAliases
      # Most complex ones were converted to abbreviations or functions
      "mnt" = "mount | awk -F' ' '{ printf \"%s\t%s\\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort";
    };

    # Fish config
    interactiveShellInit = ''
      # Set default libvirt URI for virt-manager
      set -x LIBVIRT_DEFAULT_URI "qemu:///system"
      
      # Set fish_greeting to empty to disable greeting
      set -U fish_greeting

      # Enable vi mode with explicit settings to ensure the mode is correctly detected by Starship
      fish_vi_key_bindings
      set -g fish_cursor_default block
      set -g fish_cursor_insert line
      set -g fish_cursor_visual underscore

      # Custom function to handle vi mode changes and expose them to Starship
      function on_fish_bind_mode --on-variable fish_bind_mode
        # export the vi_mode_symbol variable which Starship can use
        set --global --export vi_mode_symbol ""

        # Set vi_mode_symbol based on the current mode with colors
        if test "$fish_key_bindings" = fish_vi_key_bindings
          set --local color
          set --local symbol
          switch $fish_bind_mode
            case default
              set color blue
              set symbol N
            case insert
              set color green
              set symbol I
            case replace replace_one
              set color red
              set symbol R
            case visual
              set color yellow
              set symbol V
            case '*'
              set color cyan
              set symbol "?"
          end
          set vi_mode_symbol (set_color --bold $color)"[$symbol]"(set_color normal)
        end
      end

      # Initial call to set the mode indicator
      on_fish_bind_mode

      # Add Alt+S keyboard shortcut for sudo !!
      bind \es 'echo "sudo !!"; commandline "sudo !!"'

      # SSH agent initialization and connection reuse
      # Create SSH control directory if it doesn't exist
      mkdir -p ~/.ssh/sockets

      # Start keychain to manage SSH keys persistently without auto-adding keys
      if command -v keychain >/dev/null
        # Use keychain but don't automatically add keys
        keychain --quiet --noask

        # Load keychain environment variables
        if test -f ~/.keychain/(hostname)-fish
          source ~/.keychain/(hostname)-fish
        end
      # Fallback to manual SSH agent if keychain is not available
      else
        # Start SSH agent if not already running
        if not set -q SSH_AUTH_SOCK
          eval (ssh-agent -c)
        end

        # Note: We no longer automatically add keys on startup
        # Users can manually run `ssh-add ~/.ssh/github_nxfi` when needed
      end

      # Set fish colors (can be customized)
      set -U fish_color_normal normal
      set -U fish_color_command blue
      set -U fish_color_param cyan
      set -U fish_color_redirection yellow
      set -U fish_color_comment red
      set -U fish_color_error brred
      set -U fish_color_escape bryellow
      set -U fish_color_operator bryellow
      set -U fish_color_end brmagenta
      set -U fish_color_quote green
      set -U fish_color_autosuggestion 555
      set -U fish_color_valid_path --underline

      # Setup sudo !! functionality like in Zsh
      function sudo --description "Replacement for sudo with bang-bang (!!) expansion"
        if test (count $argv) -gt 0 && test "$argv[1]" = "!!"
          # Execute the last command with sudo
          set -l last_cmd (history | head -n1)
          echo "sudo $last_cmd"
          eval "command sudo $last_cmd"
        else
          # Regular sudo behavior
          command sudo $argv
        end
      end

      # Define a robust Git branch helper function
      function __git_branch_name
        echo (git symbolic-ref --short HEAD 2>/dev/null; or git describe --tags --exact-match 2>/dev/null; or git rev-parse --short HEAD 2>/dev/null)
      end

      # Define a robust git status checker function
      function __git_is_dirty
        not git diff --quiet --ignore-submodules HEAD 2>/dev/null
      end

      # Load and configure custom prompt using nerdfonts
      # fish_prompt is handled by Starship - just provide empty function
      function fish_prompt
        # Empty - Starship will handle this
      end

      function __format_time
        set -l milliseconds $argv[1]

        if test $milliseconds -lt 1000
          # Less than a second
          echo -n "$milliseconds"ms
          return
        end

        set -l seconds (math "round($milliseconds / 1000)")
        set -l minutes (math "floor($seconds / 60)")
        set -l hours (math "floor($minutes / 60)")
        set -l days (math "floor($hours / 24)")

        # Extract parts
        set -l d_seconds (math "$seconds % 60")
        set -l d_minutes (math "$minutes % 60")
        set -l d_hours (math "$hours % 24")

        # Create output
        set -l output ""

        if test $days -gt 0
          set output "$output$days"d
        end

        if test $d_hours -gt 0
          set output "$output$d_hours"h
        end

        if test $d_minutes -gt 0
          set output "$output$d_minutes"m
        end

        if test $d_seconds -gt 0
          set output "$output$d_seconds"s
        end

        echo -n $output
      end

      # fish_right_prompt is handled by Starship - just provide empty function
      function fish_right_prompt
        # Empty - Starship will handle this
      end

      # Vi mode indicator
      # Empty mode prompt - we'll handle this in fish_prompt instead
      function fish_mode_prompt
      end

      # Helper function to get vi mode indicator
      # Remove the __vi_mode_prompt function as it's no longer needed
      # Starship will handle vi mode indicators

      # Ensure the vi mode prompt isn't overridden by other settings
      set -g fish_vi_force_cursor 1
    '';
  };
}
