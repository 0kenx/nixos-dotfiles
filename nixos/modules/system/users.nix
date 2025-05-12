{ config, pkgs, lib, inputs, username, host, channel, ... }:

{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  
  # Define custom option for our use in other modules
  options.users.defaultUserName = lib.mkOption {
    type = lib.types.str;
    default = username;
    description = "Default username for the system";
  };
  
  config = {
    # Set the default username value 
    users.defaultUserName = username;
    
    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;
      backupFileExtension = "backup";
      extraSpecialArgs = { inherit inputs username host; };
      users.${username} = {
        imports = [ ../../home ];
        home.username = "${username}";
        home.homeDirectory = "/home/${username}";
        home.stateVersion = "${channel}";
        programs.home-manager.enable = true;
      };
    };
    
    # Define a user account. Don't forget to set a password with 'passwd'.
    # First create a group for the user
    users.groups.${username} = {};

    # Then create the user with the group assigned
    users.users.${username} = {
      isNormalUser = true;
      description = "${username}";
      group = "${username}"; # Set the primary group
      extraGroups = [ "networkmanager" "input" "wheel" "video" "audio" "tss" ];
      shell = pkgs.fish;
      openssh.authorizedKeys.keyFiles = [
        ../../hosts/common/keys/id_yubidef.pub
      ];
      packages = with pkgs; [
        youtube-music
        discord
        tdesktop
        vscodium
        brave
        chromium
        google-chrome
      ];
    };

    nix.settings.allowed-users = [ "${username}" ];

    # Change runtime directory size
    services.logind.extraConfig = "RuntimeDirectorySize=32G";
  };
}