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

        # Select file listing command based on git repo presence
        set -l file_cmd
        if git rev-parse --is-inside-work-tree 2>/dev/null
          set file_cmd "git ls-files | grep -E \"\.($filter_exts)\$\""
        else
          set file_cmd "find . -type f | grep -E \"\.($filter_exts)\$\""
        end

        # Display included extensions
        set -l display_exts (string replace -a "|" ", " $filter_exts)
        echo "Included extensions: $display_exts"

        # Count total lines
        echo "Total SLOC:"
        eval $file_cmd | xargs cat 2>/dev/null | \
          grep -v "^[[:space:]]*\$" | \
          grep -v "^[[:space:]]*[{}\\\\[\\\\]()]*[[:space:]]*\$" | \
          grep -v "^[[:space:]]*//" | \
          grep -v "^[[:space:]]*--" | \
          grep -v "^[[:space:]]*#" | \
          grep -v "^[[:space:]]*'" | \
          wc -l

        # Show detailed file listing if not in summary mode
        if not set -q _flag_summary
          set -l file_data
          set -l max_count 0

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

          # Get max count length for proper alignment
          for file in (eval $file_cmd)
            set -l count (count_lines $file)
            if test (string length $count) -gt $max_count
              set max_count (string length $count)
            end
            set -a file_data "$count:$file"
          end

          # Sort and display results
          if set -q _flag_descending
            # Sort by line count (descending)
            for item in $file_data
              set -l count (string split ":" $item)[1]
              set -l file (string split ":" $item)[2]
              printf "%"$max_count"d  %s\\n" $count $file
            end | sort -nr
          else
            # Sort by filename (default)
            for item in $file_data
              set -l count (string split ":" $item)[1]
              set -l file (string split ":" $item)[2]
              printf "%"$max_count"d  %s\\n" $count $file
            end | sort -k2
          end
        end

        # Always show the summary by file type
        echo -e "\\nSummary by file type:"
        for ext in (eval $file_cmd | sed -E 's/.*\\.([^.]+)$/\\1/' | sort | uniq)
          set -l ext_cmd "$file_cmd | grep \"\\.$ext\$\""
          set -l count (eval $ext_cmd | xargs cat 2>/dev/null | \
            grep -v "^[[:space:]]*\$" | \
            grep -v "^[[:space:]]*[{}\\\\[\\\\]()]*[[:space:]]*\$" | \
            grep -v "^[[:space:]]*//" | \
            grep -v "^[[:space:]]*--" | \
            grep -v "^[[:space:]]*#" | \
            grep -v "^[[:space:]]*'" | \
            wc -l)
          printf "%6d  .%s\\n" $count $ext
        end | if set -q _flag_descending; sort -nr; else sort -k2; end
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
        keychain --quiet --noask --agents ssh

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
