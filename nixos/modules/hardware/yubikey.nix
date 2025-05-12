{ pkgs, lib, config, ... }:

let
  username = config.users.defaultUserName;
in
{
  # Add udev rules for YubiKey devices
  services.udev = {
    packages = [
      pkgs.yubikey-personalization
      pkgs.libu2f-host
    ];
    # Add explicit rules for YubiKey detection
    extraRules = ''
      # YubiKey udev rules to ensure device is accessible
      ACTION=="add|change", SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0121|0200|0402|0403|0406|0407|0410", TAG+="systemd", ENV{SYSTEMD_WANTS}="pcscd.service"

      # Make the YubiKey accessible to users in the input group
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0113|0114|0115|0116|0120|0121|0200|0402|0403|0406|0407|0410", MODE="0660", GROUP="input"
    '';
  };

  # Configure PCSCD with improved systemd integration
  services.pcscd = {
    enable = true;
    # Critical: Make pcscd a system-level service that can start early during boot
    socketActivation = true;
    plugins = [ pkgs.ccid ];
  };

  # Enable YubiKey agent with systemd integration
  services.yubikey-agent = {
    enable = true;
    # Ensure this starts after pcscd
    startAfter = [ "pcscd.service" ];
  };

  # Enable GPG agent with SSH integration for YubiKey
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryFlavor = "gtk2"; # Use GTK for PIN entry
  };

  # Enable SSH agent at system level
  programs.ssh.startAgent = true;

  # PAM U2F configuration for YubiKey authentication
  security.pam.u2f = {
    enable = true;
    debug = false; # Set to true when troubleshooting
    settings = {
      cue = true; # Show prompt when waiting for touch
      cue_prompt = "Touch YubiKey to continue..."; # Custom prompt for yubikey touch
      interactive = true; # Interactive mode for better user feedback
      # Create authorization mapping in the user's home directory
      authfile = "/home/${username}/.config/Yubico/u2f_keys";
      # Recommended: Origin pattern for enhanced security
      origin = "pam://nixos";
      # Recommended: Application ID for enhanced security
      appid = "pam://nixos";
    };
    # This will allow falling back to password if YubiKey is not present
    control = "sufficient";
  };

  # Enhanced PAM service configuration
  security.pam.services = {
    login.u2fAuth = true;
    greetd.u2fAuth = true;
    sudo.u2fAuth = true;
    sudo.sshAgentAuth = true;
    hyprlock.u2fAuth = true;
    tuigreet.u2fAuth = true;

    # Add support for PKCS#11 authentication
    sudo.googleAuthenticator.enable = false;
    login.googleAuthenticator.enable = false;

    # We'll configure PAM via the global settings instead
  };

  # More comprehensive package collection for YubiKey support
  environment.systemPackages = with pkgs; [
    yubikey-manager            # YubiKey management CLI
    yubikey-manager-qt         # GUI for YubiKey management
    yubico-pam                 # PAM module for YubiKey
    yubioath-flutter           # GUI for OATH codes
    pam_u2f                    # PAM module for U2F
    opensc                     # Smart card utilities
    pcsc-tools                 # Tools for PC/SC smart cards
    pcsctools                  # Additional tools for smart cards
    gnupg                      # GPG for key management
    pinentry-gtk2              # PIN entry dialog
    libu2f-host                # U2F host library
    libfido2                   # FIDO2 library
    openssh                    # Ensure latest OpenSSH with YubiKey support
  ];

  # Create directories and files needed by YubiKey services
  systemd.tmpfiles.rules = [
    "d /run/pcscd 0755 root root - -"
    "f /run/pcscd/pcscd.pid 0644 root root - -"
    "d /var/cache/pcscd 0750 root root - -"
  ];

  # Make YubiKey-related services start before the login manager
  systemd.services = {
    pcscd = {
      wantedBy = [ "multi-user.target" ];
      before = [ "display-manager.service" ];
      requires = [ "dbus.service" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.pcsclite}/sbin/pcscd --foreground --auto-exit";
        Restart = "on-failure";
      };
    };

    yubikey-agent = {
      wantedBy = [ "multi-user.target" ];
      after = [ "pcscd.service" ];
      requires = [ "pcscd.service" ];
      before = [ "display-manager.service" ];
    };
  };

  # Add script to initialize the u2f_keys file with improved detection
  system.activationScripts.yubikey-setup = lib.stringAfter [ "users" ] ''
    # Create YubiKey configuration directory
    mkdir -p /home/${username}/.config/Yubico

    # Create or check u2f_keys file
    if [ ! -f /home/${username}/.config/Yubico/u2f_keys ]; then
      echo "Creating u2f_keys file for ${username}"
      touch /home/${username}/.config/Yubico/u2f_keys
    fi

    # Ensure proper permissions for YubiKey files
    chown -R ${username}:${username} /home/${username}/.config/Yubico
    chmod 700 /home/${username}/.config/Yubico
    chmod 600 /home/${username}/.config/Yubico/u2f_keys

    # Detect if YubiKeys are present and help the user set them up
    if [ -x ${pkgs.yubikey-manager}/bin/ykman ]; then
      YUBIKEYS=$(${pkgs.yubikey-manager}/bin/ykman list 2>/dev/null || echo "")
      if [ -n "$YUBIKEYS" ] && [ ! -s /home/${username}/.config/Yubico/u2f_keys ]; then
        echo "YubiKey detected, but not registered for authentication."
        echo "Run 'pamu2fcfg > ~/.config/Yubico/u2f_keys' while touching your YubiKey to register it."
      fi
    fi
  '';
}
