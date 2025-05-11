{pkgs, username, config, lib, ...}: {
  programs.ssh = {
    enable = true;
    
    # Matches and extends your existing SSH config
    matchBlocks = {
      "nx-fi" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/github_nxfi";
        extraOptions = {
          "AddKeysToAgent" = "yes";
        };
      };
      
      "*" = {
        extraOptions = {
          # Use the Nix store path for the PKCS11 provider
          # This will be properly interpolated at build time
          "PKCS11Provider" = "${pkgs.opensc}/lib/opensc-pkcs11.so";
        };
      };
    };
  };
}