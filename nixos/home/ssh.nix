{pkgs, username, config, lib, ...}: {
  # Enable SSH agent service
  services.ssh-agent.enable = true;

  # Install keychain for persistent SSH agent management
  home.packages = with pkgs; [
    keychain
  ];

  programs.ssh = {
    enable = true;

    # Disable default config values (deprecated in newer home-manager)
    enableDefaultConfig = false;

    # Matches and extends your existing SSH config
    matchBlocks = {
      "nx-fi" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_nxfi";
        identitiesOnly = true;
        extraOptions = {
          "AddKeysToAgent" = "yes";
          "ControlMaster" = "no";
        };
      };

      # Personal GitHub (default)
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_personal";
        identitiesOnly = true;
        extraOptions = {
          "AddKeysToAgent" = "yes";
          "ControlMaster" = "no";
        };
      };

      # Work GitHub (use git@work:org/repo.git)
      "work" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519_work";
        identitiesOnly = true;
        extraOptions = {
          "AddKeysToAgent" = "yes";
          "ControlMaster" = "no";
        };
      };

      "*" = {
        forwardAgent = true;
        extraOptions = {
          # Comment out PKCS11Provider to prevent it from being used globally
          # "PKCS11Provider" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
          "AddKeysToAgent" = "yes";
          "ServerAliveInterval" = "60";
        };
      };
    };
  };

  # SSH directory is created by the SSH module
}