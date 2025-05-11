{pkgs, username, host, config, ...}: {
  programs.git = {
    enable = true;
    
    # User information from SOPS secrets
    # These are read from environment variables that point to the secret files
    userName = "$(cat $GIT_DEFAULT_NAME)";
    userEmail = "$(cat $GIT_DEFAULT_EMAIL)";
    
    # Signing configuration from SOPS secrets
    signing = {
      key = "$(cat $GIT_SIGNING_KEY)";
      signByDefault = true;
    };
    
    # Core settings
    extraConfig = {
      core = {
        pager = "delta";
      };
      
      # Interactive mode
      interactive = {
        diffFilter = "delta --color-only";
      };
      
      # Delta configuration
      delta = {
        features = "catppuccin-macchiato";
      };
    };
    
    # Conditional includes for different directories
    # Uses SOPS secrets to avoid hardcoding identities in git config
    includes = [
      {
        condition = "gitdir:~/projects/";
        contents = {
          user = {
            name = "$(cat $GIT_PERSONAL_NAME)";
            email = "$(cat $GIT_PERSONAL_EMAIL)";
          };
        };
      }
      {
        condition = "gitdir:~/work/";
        contents = {
          user = {
            name = "$(cat $GIT_WORK_NAME)";
            email = "$(cat $GIT_WORK_EMAIL)";
          };
        };
      }
    ];
    
    # Git Ignore
    ignores = [
      # OS specific
      ".DS_Store"
      "Thumbs.db"
      
      # Editor files
      ".vscode/"
      ".idea/"
      "*.swp"
      "*.swo"
      "*~"
      
      # Compilation artifacts
      "*.o"
      "*.so"
      "*.dylib"
      "*.a"
      "*.out"
      "*.exe"
      
      # Python
      "__pycache__/"
      "*.py[cod]"
      "*$py.class"
      "*.so"
      ".Python"
      "env/"
      "build/"
      "develop-eggs/"
      "dist/"
      "downloads/"
      "eggs/"
      ".eggs/"
      "lib/"
      "lib64/"
      "parts/"
      "sdist/"
      "var/"
      "wheels/"
      "*.egg-info/"
      ".installed.cfg"
      "*.egg"
      
      # Node.js
      "node_modules/"
      "npm-debug.log"
      "yarn-error.log"
      
      # Rust
      "target/"
      "Cargo.lock"
      
      # Logs
      "*.log"
      "logs/"
      
      # Environment variables
      ".env"
      ".env.local"
      ".env.development.local"
      ".env.test.local"
      ".env.production.local"
    ];
  };
  
  # Delta - A better diff viewer
  programs.delta = {
    enable = true;
    options = {
      features = "catppuccin-macchiato";
      
      # Catppuccin Macchiato theme settings for Delta
      "catppuccin-macchiato" = {
        "blame-palette" = "#24273a #1e2030 #181926 #363a4f #494d64";
        "commit-decoration-style" = "box ul";
        "dark" = "true";
        "file-decoration-style" = "#cad3f5";
        "file-style" = "#cad3f5";
        "hunk-header-decoration-style" = "box ul";
        "hunk-header-file-style" = "bold";
        "hunk-header-line-number-style" = "bold #a5adcb";
        "hunk-header-style" = "file line-number syntax";
        "line-numbers-left-style" = "#6e738d";
        "line-numbers-minus-style" = "bold #ed8796";
        "line-numbers-plus-style" = "bold #a6da95";
        "line-numbers-right-style" = "#6e738d";
        "line-numbers-zero-style" = "#6e738d";
        "minus-emph-style" = "bold syntax #563f51";
        "minus-style" = "syntax #383143";
        "plus-emph-style" = "bold syntax #455450";
        "plus-style" = "syntax #313943";
        "map-styles" = "bold purple => syntax #4d4569, bold blue => syntax #3e4868, bold cyan => syntax #3f5364, bold yellow => syntax #575253";
        "syntax-theme" = "Catppuccin Macchiato";
      };
    };
  };
}