{inputs, username, host, ...}: {
  programs.starship = {
    enable = false; # Disabled to use custom fish prompt
    settings = {
      aws = {
        symbol = "󰸏 ";
        format = "\\[[$symbol($profile)(\\($region\\))(\\[$duration\\])]($style)\\]";
      };
      bun = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      c = {
        symbol = " ";
        format = "\\[[$symbol($version(-$name))]($style)\\]";
      };
      cmake = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      cmd_duration = {
        format = "\\[[⏱ $duration]($style)\\]";
      };
      cobol = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      conda = {
        format = "\\[[$symbol$environment]($style)\\]";
      };
      crystal = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      daml = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      dart = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      deno = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      docker_context = {
        symbol = " ";
        format = "\\[[$symbol$context]($style)\\]";
      };
      dotnet = {
        symbol = "󰪮 ";
        format = "\\[[$symbol($version)(🎯 $tfm)]($style)\\]";
      };
      elixir = {
        symbol = " ";
        format = "\\[[$symbol($version \\(OTP $otp_version\\))]($style)\\]";
      };
      elm = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      erlang = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      gcloud = {
        symbol = " ";
        format = "\\[[$symbol$account(@$domain)(\\($region\\))]($style)\\]";
      };
      git_branch = {
        format = "\\[[$symbol$branch]($style)\\]";
      };
      git_status = {
        format = "(\\[[$all_status$ahead_behind\\]]($style))";
      };
      golang = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      guix_shell = {
        symbol = " ";
        format = "\\[[$symbol]($style)\\]";
      };
      haskell = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      haxe = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      helm = {
        symbol = "⎈ ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      hg_branch = {
        format = "\\[[$symbol$branch]($style)\\]";
      };
      java = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      julia = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      kotlin = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      kubernetes = {
        symbol = "󱃾 ";
        format = "\\[[$symbol$context( \\($namespace\\))]($style)\\]";
      };
      lua = {
        symbol = "󰢱 ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      memory_usage = {
        format = "\\[$symbol[$ram( | $swap)]($style)\\]";
      };
      meson = {
        format = "\\[[$symbol$project]($style)\\]";
      };
      nim = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      nix_shell = {
        symbol = " ";
        format = "\\[[$symbol$state( \\($name\\))]($style)\\]";
      };
      nodejs = {
        symbol = "󰎙 ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      ocaml = {
        symbol = " ";
        format = "\\[[$symbol($version)(\\($switch_indicator$switch_name\\))]($style)\\]";
      };
      opa = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      openstack = {
        format = "\\[[$symbol$cloud(\\($project\\))]($style)\\]";
      };
      os = {
        format = "\\[[$symbol]($style)\\]";
      };
      package = {
        format = "\\[[$symbol$version]($style)\\]";
      };
      perl = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      php = {
        symbol = "󰌟 ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      pulumi = {
        format = "\\[[$symbol$stack]($style)\\]";
      };
      purescript = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      python = {
        symbol = " ";
        format = "\\[[$symbol$$pyenv_prefix($version)(\\($virtualenv\\))]($style)\\]";
      };
      raku = {
        format = "\\[[$symbol($version-$vm_version)]($style)\\]";
      };
      red = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      ruby = {
        symbol = "󰴭 ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      rust = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      scala = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      spack = {
        format = "\\[[$symbol$environment]($style)\\]";
      };
      sudo = {
        format = "\\[[as $symbol]\\]";
      };
      swift = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      terraform = {
        symbol = " ";
        format = "\\[[$symbol$workspace]($style)\\]";
      };
      time = {
        format = "\\[[$time]($style)\\]";
      };
      username = {
        format = "\\[[$user]($style)\\]";
      };
      vagrant = {
        format = "\\[[$symbol($version)]($style)\\]";
      };
      vlang = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
      zig = {
        symbol = " ";
        format = "\\[[$symbol($version)]($style)\\]";
      };
    };
  };
}