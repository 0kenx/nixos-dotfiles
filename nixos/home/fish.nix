{inputs, username, host, ...}: {
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
      
      # apt related (these are likely not needed in NixOS, but kept for reference)
      sapti = "sudo apt install -y";
      saptd = "sudo apt install";
      saptg = "sudo apt update && sudo apt upgrade";
      saptr = "sudo apt remove";
      
      # sys related
      rm = "rmtrash";
      rmdir = "rmdirtrash";
      "ch+x" = "sudo chmod +x";
      "cha+x" = "sudo chmod +x";
      hs = "history | grep";
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
      now = "date +\"%T\"";
      nowtime = "date +\"%T\"";
      nowdate = "date +\"%d-%m-%Y\"";
      ping = "ping -c 5";
      gfw = "proxychains4 !!";
      ports = "netstat -tulanp";
      meminfo = "free -m -l -t";
      diff = "colordiff";
      p = "parallel";
      pp = "parallel --pipe -k";
      vifm = "vifmrun";
      
      # temp fixes
      cursor = "/home/benji/soft/squashfs-root/AppRun";
      
      # source mirrors
      pip3tsu = "python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple";
      piptsu = "python -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple";
      pip3db = "python3 -m pip install -i https://pypi.douban.com/simple";
      pipdb = "python -m pip install -i https://pypi.douban.com/simple/";
      
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
      hg = "history | grep";
      
      # docker
      dcl = "docker container ls";
    };

    # Fish shell functions
    functions = {
      # Autostart function that doesn't launch waybar (to prevent duplicate instances)
      autostart_no_waybar = ''
        # Start essential services but NOT waybar (handled by systemd)
        # Assuming this is similar to the autostart function, but without waybar
        pypr & hyprpaper & poweralertd -s & wl-paste --type text --watch cliphist store & wl-paste --type image --watch cliphist store & wl-clip-persist --clipboard regular & avizo-service & systemctl --user start psi-notify
      '';

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
    };

    shellAliases = {
      # The basic aliases are better as shellAliases
      # Most complex ones were converted to abbreviations or functions
      "mnt" = "mount | awk -F' ' '{ printf \"%s\t%s\\n\",\$1,\$3; }' | column -t | egrep ^/dev/ | sort";
    };

    # Fish config
    interactiveShellInit = ''
      # Set fish_greeting to empty to disable greeting
      set -U fish_greeting
      
      # Enable vi mode
      fish_vi_key_bindings
      set -g fish_cursor_default block
      set -g fish_cursor_insert line
      set -g fish_cursor_visual underscore
      
      # Add Alt+S keyboard shortcut for sudo !!
      bind \es 'echo "sudo !!"; commandline "sudo !!"'

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
      function fish_prompt
        # Save the status
        set -l last_status $status
        
        # Vi mode indicator
        echo -n "["
        __vi_mode_prompt
        echo -n "]"
        
        # Username (no hostname)
        set_color blue
        echo -n (whoami)
        set_color normal
        echo -n ' '
        
        # Current directory
        set_color blue
        echo -n (prompt_pwd)
        set_color normal
        
        # Git status if in a git repo
        if git rev-parse --is-inside-work-tree >/dev/null 2>&1
          set -l branch (__git_branch_name)
          
          if test -n "$branch"
            set_color normal
            echo -n ' ('
            
            # Branch name
            set_color yellow
            echo -n "$branch"
            set_color normal
            echo -n ')'
            
            # Number of untracked, staged and changed files
            set -l git_status (git status --porcelain 2>/dev/null)
            
            # Count added, modified and untracked files
            set -l added_count (echo $git_status | grep -c -E '^A|^M')
            set -l modified_count (echo $git_status | grep -c -E '^ M|^MM')
            set -l untracked_count (echo $git_status | grep -c -E '^\?\?')
            
            # Count unpushed commits
            set -l unpushed_count 0
            set -l current_remote (git rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
            if test $status -eq 0
              # Successfully got upstream branch, count unpushed commits
              set unpushed_count (git log --oneline $current_remote..HEAD 2>/dev/null | wc -l)
            else
              # No upstream branch found, count all commits
              set -l has_commits (git log -1 --oneline 2>/dev/null)
              if test -n "$has_commits"
                # Repository has commits but no upstream
                set unpushed_count (git log --oneline 2>/dev/null | wc -l)
              end
            end
            
            # Display statistics if there are any changes
            if test $added_count -gt 0
              set_color green
              echo -n "+$added_count"
              set_color normal
            end
            
            if test $modified_count -gt 0
              set_color yellow
              echo -n "!$modified_count"
              set_color normal
            end
            
            if test $untracked_count -gt 0
              set_color red
              echo -n "?$untracked_count"
              set_color normal
            end
            
            if test $unpushed_count -gt 0
              set_color cyan
              echo -n "↑$unpushed_count"
              set_color normal
            end
          end
        end
        
        # Prompt character
        set_color normal
        echo -n ' > '
        
        set_color normal
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
      
      function fish_right_prompt
        set -l last_status $status
        
        # Command status indicator
        if test $last_status -eq 0
          set_color green
          echo -n "✓ "
        else
          set_color red
          echo -n "✗ $last_status"
        end
        
        # Command execution time
        if set -q CMD_DURATION
          set -l duration (__format_time $CMD_DURATION)
          if test -n "$duration"
            set_color brblack
            echo -n "|$duration"
          end
        end
        
        # Clock 
        set_color brblack
        echo -n "|"(date "+%H:%M:%S")
        
        set_color normal
      end
      
      # Vi mode indicator
      # Empty mode prompt - we'll handle this in fish_prompt instead
      function fish_mode_prompt
      end
      
      # Helper function to get vi mode indicator
      function __vi_mode_prompt
        switch $fish_bind_mode
          case default
            set_color red
            echo -n 'N'
          case insert
            set_color green
            echo -n 'I'
          case replace_one
            set_color yellow
            echo -n 'R'
          case visual
            set_color magenta
            echo -n 'V'
        end
        set_color normal
      end
    '';
  };
}
