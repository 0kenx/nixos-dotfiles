{config, lib, pkgs, ...}: {
  imports = [
    ../modules/per-host.nix
  ];
  
  # Configuration specific to this host
  nixosConfig.system.nixos-dotfiles = {
    git = {
      user = {
        name = "0kenx";  # Replace with the actual username for this host
        email = "km@nxfi.app";  # Replace with the actual email for this host
        signingKey = "73834AA6FB6DD8B0";  # Replace with the actual signing key for this host
      };
      includes = [
        {
          condition = "gitdir:~/projects/";
          contents = {
            user = {
              name = "0kenx"; 
              email = "km@nxfi.app";
            };
          };
        }
        {
          condition = "gitdir:~/work/";
          contents = {
            user = {
              name = "Ken Miller";
              email = "ken.miller@work.com";
            };
          };
        }
      ];
    };
    
    hyprland = {
      monitors = [
        "eDP-1,preferred,auto,1.6"
        "HDMI-A-1,preferred,auto-up,1.6"
      ];
    };
  };
}