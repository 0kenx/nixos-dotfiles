{inputs, username, host, ...}: {
  programs.starship = {
    enable = true;
    settings = {
      # Create a compact format with custom vim mode indicator
      format = "$custom$username $directory$git_branch$git_status$git_metrics $character";
      right_format = "$status$cmd_duration$python$nodejs$rust$c$golang$zig$lua$time";
      add_newline = false;

      # Define the character module for the prompt character
      character = {
        success_symbol = "[>](bold green)";
        error_symbol = "[>](bold red)";
        vimcmd_symbol = "[>](bold blue)";
      };

      # Configure the username display
      username = {
        style_user = "blue bold";
        style_root = "red bold";
        format = "[$user]($style)";
        disabled = false;
        show_always = true;
      };

      # Configure directory display
      directory = {
        style = "blue";
        format = "[$path]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
        fish_style_pwd_dir_length = 1;
      };

      # Configure git branch display with tracking info
      git_branch = {
        symbol = "";
        style = "bold yellow";
        format = " \\([$branch(:$remote_branch)]($style)\\) ";
        always_show_remote = true;
      };

      # Configure git status display
      git_status = {
        format = "[$all_status$ahead_behind](bold red)";
        ahead = "↑$count";
        behind = "↓$count";
        diverged = "⇕↑$ahead_count⇣$behind_count";
        stashed = "≡$count";
        staged = "+$count";
        conflicted = "!$count";
        untracked = "?$count";
        modified = "!$count";
        up_to_date = "";
        ignore_submodules = false;
        ahead_behind_separator = "";
        use_git_executable = true;
      };

      # Git metrics to show added/deleted lines
      git_metrics = {
        disabled = false;
        added_style = "bold green";
        deleted_style = "bold red";
        only_nonzero_diffs = true;
        format = "([+$added]($added_style) )([-$deleted]($deleted_style) )";
      };

      # Git commit module to show unpushed commits
      git_commit = {
        only_detached = false;
        format = "[$hash]($style) ";
        style = "bold yellow";
      };

      # Command duration display
      cmd_duration = {
        min_time = 0;
        format = " [$duration](bright-black)";
        show_milliseconds = true;
      };

      # Configure the time display
      time = {
        disabled = false;
        format = "[|$time](bright-black)";
        time_format = "%H:%M:%S";
      };

      # Configure the status display
      status = {
        disabled = false;
        format = "[$symbol]($style)";
        symbol = "✘ $status";
        success_symbol = "✓";
        style = "red bold";
        success_style = "green bold";
        map_symbol = true;
      };

      # Make a custom vi_mode Starship section
      custom.vi_mode = {
        command = "echo $vi_mode_symbol";
        when = "test -n \"$vi_mode_symbol\"";
        format = "$output";
      };

      # Configure language-specific modules
      python = {
        disabled = false;
        format = "[(py $version)](blue bold) ";
        detect_extensions = ["py"];
      };
      nodejs = {
        disabled = false;
        format = "[(node $version)](green bold) ";
        detect_extensions = ["js" "mjs" "cjs" "ts" "mts" "cts"];
      };
      rust = {
        disabled = false;
        format = "[(rust $version)](red bold) ";
        detect_extensions = ["rs"];
      };
      c = {
        disabled = false;
        format = "[(c $version)](blue bold) ";
        detect_extensions = ["c" "h"];
      };
      golang = {
        disabled = false;
        format = "[(go $version)](cyan bold) ";
        detect_extensions = ["go"];
      };
      zig = {
        disabled = false;
        format = "[(zig $version)](yellow bold) ";
        detect_extensions = ["zig"];
      };
      lua = {
        disabled = false;
        format = "[(lua $version)](blue bold) ";
        detect_extensions = ["lua"];
      };

      # Disable other modules
      aws = { disabled = true; };
      bun = { disabled = true; };
      cmake = { disabled = true; };
      cobol = { disabled = true; };
      conda = { disabled = true; };
      crystal = { disabled = true; };
      daml = { disabled = true; };
      dart = { disabled = true; };
      deno = { disabled = true; };
      docker_context = { disabled = true; };
      dotnet = { disabled = true; };
      elixir = { disabled = true; };
      elm = { disabled = true; };
      erlang = { disabled = true; };
      gcloud = { disabled = true; };
      guix_shell = { disabled = true; };
      haskell = { disabled = true; };
      haxe = { disabled = true; };
      helm = { disabled = true; };
      hg_branch = { disabled = true; };
      java = { disabled = true; };
      julia = { disabled = true; };
      kotlin = { disabled = true; };
      kubernetes = { disabled = true; };
      memory_usage = { disabled = true; };
      meson = { disabled = true; };
      nim = { disabled = true; };
      nix_shell = { disabled = false; };
      ocaml = { disabled = true; };
      opa = { disabled = true; };
      openstack = { disabled = true; };
      os = { disabled = true; };
      package = { disabled = true; };
      perl = { disabled = true; };
      php = { disabled = true; };
      pulumi = { disabled = true; };
      purescript = { disabled = true; };
      raku = { disabled = true; };
      red = { disabled = true; };
      ruby = { disabled = true; };
      scala = { disabled = true; };
      spack = { disabled = true; };
      sudo = { disabled = true; };
      swift = { disabled = true; };
      terraform = { disabled = true; };
      vagrant = { disabled = true; };
      vlang = { disabled = true; };
    };
  };
}

