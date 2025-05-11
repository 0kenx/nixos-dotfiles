{ pkgs, lib, config, ... }:

let
  username = config.users.defaultUserName;
in
{
  services.udev.packages = [ pkgs.yubikey-personalization ];

  # programs.ssh.startAgent = true;

  services.yubikey-agent.enable = true;

  # PAM U2F configuration for Yubikey authentication
  security.pam.u2f = {
    enable = true;
    settings.cue = true;
    control = "sufficient";
    # Create authorization mapping in the user's home directory
    authFile = "/home/${username}/.config/Yubico/u2f_keys";
  };

  security.pam.services = {
    login.u2fAuth = true;
    greetd.u2fAuth = true;
    sudo.u2fAuth = true;
    sudo.sshAgentAuth = true;
    hyprlock.u2fAuth = true;
  };

  # Add yubikey-related packages
  environment.systemPackages = with pkgs; [
    yubikey-manager
    yubioath-flutter
    pam_u2f
    opensc
    pcsc-tools
  ];
  
  # Enable the PCSCD daemon for Yubikey
  services.pcscd.enable = true;
  
  # We configure the SOPS age SSH key paths in modules/secrets.nix
  
  # Add script to initialize the u2f_keys file
  system.activationScripts.yubikey-setup = lib.stringAfter [ "users" ] ''
    mkdir -p /home/${username}/.config/Yubico
    if [ ! -f /home/${username}/.config/Yubico/u2f_keys ]; then
      echo "Creating u2f_keys file for ${username}"
      touch /home/${username}/.config/Yubico/u2f_keys
      chown ${username}:users /home/${username}/.config/Yubico/u2f_keys
      chmod 600 /home/${username}/.config/Yubico/u2f_keys
    fi
  '';
}
