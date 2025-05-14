{inputs, username, host, ...}: {
  programs.starship = {
    enable = true;
    settings = {
      # Create a compact format with custom vim mode indicator
      format = "$custom$username $directory$git_branch$git_status $character";
      right_format = "$status$cmd_duration$time";
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

      # Configure git branch display
      git_branch = {
        symbol = "";
        style = "bold yellow";
        format = " \\([$branch]($style)\\)";
      };

      # Configure git status display
      git_status = {
        format = "[$all_status$ahead_behind](bold red)";
        ahead = "↑$count";
        behind = "↓$count";
        diverged = "⇕↑$ahead_count↓$behind_count";
        staged = "+$count";
        conflicted = "!$count";
        untracked = "?$count";
        modified = "!$count";
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
        format = "$output ";
      };

      # Disable all unused modules
      aws = { disabled = true; };
      bun = { disabled = true; };
      c = { disabled = true; };
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
      golang = { disabled = true; };
      guix_shell = { disabled = true; };
      haskell = { disabled = true; };
      haxe = { disabled = true; };
      helm = { disabled = true; };
      hg_branch = { disabled = true; };
      java = { disabled = true; };
      julia = { disabled = true; };
      kotlin = { disabled = true; };
      kubernetes = { disabled = true; };
      lua = { disabled = true; };
      memory_usage = { disabled = true; };
      meson = { disabled = true; };
      nim = { disabled = true; };
      nix_shell = { disabled = false; };
      nodejs = { disabled = true; };
      ocaml = { disabled = true; };
      opa = { disabled = true; };
      openstack = { disabled = true; };
      os = { disabled = true; };
      package = { disabled = true; };
      perl = { disabled = true; };
      php = { disabled = true; };
      pulumi = { disabled = true; };
      purescript = { disabled = true; };
      python = { disabled = true; };
      raku = { disabled = true; };
      red = { disabled = true; };
      ruby = { disabled = true; };
      rust = { disabled = true; };
      scala = { disabled = true; };
      spack = { disabled = true; };
      sudo = { disabled = true; };
      swift = { disabled = true; };
      terraform = { disabled = true; };
      vagrant = { disabled = true; };
      vlang = { disabled = true; };
      zig = { disabled = true; };
    };
  };
}

