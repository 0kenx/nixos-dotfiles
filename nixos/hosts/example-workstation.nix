{config, lib, pkgs, ...}: {
  imports = [
    ../modules/per-host.nix
  ];
  
  # Configuration specific to this host
  nixosConfig.system.nixos-dotfiles = {
    git = {
      user = {
        name = "Ken Miller";  # Different username for work machine
        email = "ken.miller@work.com";
        signingKey = "DIFFERENT_KEY_ID";  # Different signing key
      };
      includes = [
        {
          condition = "gitdir:~/work/";
          contents = {
            user = {
              name = "Ken Miller";
              email = "ken.miller@work.com";
            };
          };
        }
        {
          condition = "gitdir:~/personal/";
          contents = {
            user = {
              name = "0kenx";
              email = "km@nxfi.app";
            };
          };
        }
      ];
    };
    
    hyprland = {
      monitors = [
        "DP-1,3840x2160@60,0x0,1.5"
        "DP-2,3840x2160@60,2560x0,1.5"
      ];
    };
  };
}