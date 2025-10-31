{ config, pkgs, lib, inputs, username, host, channel, ... }:

{
  # This import makes home-manager options available in NixOS modules.
  # It does NOT configure any specific user's home-manager setup.
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

    # IMPORTANT: ALL home-manager configuration is now centralized in flake.nix
    # DO NOT define any home-manager settings here to avoid conflicts

    # Define a user account. Don't forget to set a password with 'passwd'.
    users.users.${username} = {
      isNormalUser = true;
      description = "${username}";
      extraGroups = [ "networkmanager" "input" "wheel" "video" "audio" "tss" "storage" "plugdev" "bluetooth" "docker" "libvirtd" "podman" "serial" ];
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
