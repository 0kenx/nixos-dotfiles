{pkgs, username, config, lib, ...}: {
  # Enable SSH agent service
  services.ssh-agent.enable = true;

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
          "ControlMaster" = "auto";
          "ControlPath" = "~/.ssh/sockets/%r@%h-%p";
          "ControlPersist" = "600";
        };
      };

      "github.com" = {
        extraOptions = {
          "AddKeysToAgent" = "yes";
          "ControlMaster" = "auto";
          "ControlPath" = "~/.ssh/sockets/%r@%h-%p";
          "ControlPersist" = "600";
        };
      };

      "*" = {
        extraOptions = {
          # Use the Nix store path for the PKCS11 provider
          # This will be properly interpolated at build time
          "PKCS11Provider" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
          "AddKeysToAgent" = "yes";
          "ServerAliveInterval" = "60";
        };
      };
    };
  };

  # Create SSH control sockets directory
  home.file.".ssh/sockets/.keep".text = "";
}