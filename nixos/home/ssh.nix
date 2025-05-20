{pkgs, username, config, lib, ...}: {
  # Enable SSH agent service
  services.ssh-agent.enable = true;

  # Install keychain for persistent SSH agent management
  home.packages = with pkgs; [
    keychain
  ];

  programs.ssh = {
    enable = true;

    # Enable SSH agent integration
    forwardAgent = true;

    # Matches and extends your existing SSH config
    matchBlocks = {
      "nx-fi" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_nxfi";
        extraOptions = {
          "AddKeysToAgent" = "yes";
          "ControlMaster" = "no";
        };
      };

      "github.com" = {
        extraOptions = {
          "AddKeysToAgent" = "yes";
          "ControlMaster" = "no";
        };
      };

      "*" = {
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