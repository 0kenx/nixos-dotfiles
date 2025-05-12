{pkgs, username, config, lib, ...}: {
  programs.ssh = {
    enable = true;

    # Enhanced SSH configuration
    extraConfig = ''
      # More reliable PKCS#11 handling
      PKCS11Provider ${pkgs.opensc}/lib/opensc-pkcs11.so

      # Enable SSH agent forwarding
      ForwardAgent yes

      # Better debugging when needed (uncomment when troubleshooting)
      # LogLevel DEBUG3

      # Improve connection behavior
      ServerAliveInterval 60
      ServerAliveCountMax 3

      # Set reasonable defaults
      IdentitiesOnly yes
      AddKeysToAgent yes
    '';

    # Matches and extends your existing SSH config
    matchBlocks = {
      "nx-fi" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_nxfi";
        extraOptions = {
          # Prefer the file-based key for GitHub first
          "IdentitiesOnly" = "yes";
          "PreferredAuthentications" = "publickey";
          # Try PKCS#11 only after the file-based key
          "PKCS11Provider" = "none";
        };
      };

      # For hosts where you want to use YubiKey specifically
      "yubikey-hosts" = {
        host = "github.com gitlab.com"; # Add more hosts as needed
        extraOptions = {
          "PKCS11Provider" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
          # Extended key handling options
          "ChallengeResponseAuthentication" = "yes";
          "PubkeyAuthentication" = "yes";
        };
      };
    };
  };

  # We'll manage SSH agent through the system configuration instead
}