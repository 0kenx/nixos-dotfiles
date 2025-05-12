{ pkgs, config, ... }:

{
  # Enable Display Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time --time-format '%I:%M %p | %a • %h | %F' \
          --remember --remember-user-session \
          --issue \
          --pam-service tuigreet \
          --cmd 'uwsm start hyprland'";
        user    = "greeter";
      };
    };
  };

  users.users.greeter = {
    isNormalUser = false;
    description  = "greetd greeter user";
    extraGroups  = [ "video" "audio" "input" ];
    linger      = true;
  };

  # Create specific PAM rules for tuigreet to ensure YubiKey authentication works
  security.pam.services.tuigreet = {
    # Enable U2F authentication specifically for tuigreet
    u2fAuth = true;
  };

  # Set global PAM U2F settings instead of per-service control
  security.pam.u2f.control = "sufficient";

  # Explicit PAM configuration to ensure YubiKey works with greetd
  security.pam.services.greetd = {
    u2fAuth = true;
    startSession = true;
  };

  # Add needed packages for display manager
  environment.systemPackages = with pkgs; [
    greetd.tuigreet
    pam_u2f  # Make sure PAM U2F module is available
  ];

  # Ensure the greeter environment has access to YubiKey-related tools
  # This makes YubiKey detection more reliable during login
  systemd.tmpfiles.rules = [
    "d /run/pcscd 0755 root root - -"
    "d /run/tuigreet 0755 greeter greeter - -"
  ];
}
