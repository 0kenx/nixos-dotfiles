{pkgs, username, host, config, lib, ...}: {
  programs.git = {
    enable = true;
    
    # Use shell expansion to read from the secret files
    userName = "$(cat $GIT_DEFAULT_NAME 2>/dev/null || echo 'Default User')";
    userEmail = "$(cat $GIT_DEFAULT_EMAIL 2>/dev/null || echo 'default@example.com')";
    
    # Signing configuration (uses secret files)
    signing = {
      key = "$(cat $GIT_SIGNING_KEY 2>/dev/null || echo '0000000000000000')";
      signByDefault = true;
    };
    
    # Core settings
    extraConfig = {
      # Interactive mode
      interactive = {
        diffFilter = "delta --color-only";
      };
    };
    
    # Conditional includes for different directories
    # Uses shell commands to read from the secret files
    includes = [
      {
        condition = "gitdir:~/projects/";
        contents = {
          user = {
            name = "$(cat $GIT_PERSONAL_NAME 2>/dev/null || echo 'Personal')";
            email = "$(cat $GIT_PERSONAL_EMAIL 2>/dev/null || echo 'personal@example.com')";
          };
        };
      }
      {
        condition = "gitdir:~/work/";
        contents = {
          user = {
            name = "$(cat $GIT_WORK_NAME 2>/dev/null || echo 'Work')";
            email = "$(cat $GIT_WORK_EMAIL 2>/dev/null || echo 'work@example.com')";
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
  
  # Delta is now handled by the delta.nix module

  # Configure git extra settings
  programs.git.extraConfig = {
    # SSH credentials helper for submodules
    credential.helper = "cache --timeout=3600";

    # For handling submodules better
    submodule = {
      recurse = true;
    };

    # Use SSH connections more efficiently
    ssh = {
      variant = "ssh";
    };
  };
}