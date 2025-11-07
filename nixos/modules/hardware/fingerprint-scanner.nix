{ pkgs, lib, ... }:

{
  # Enable fingerprint scanner (Synaptics FS7605 - Device ID 06cb:00df)
  # This device is supported by libfprint 1.90.3+ (added Sept 2020)
  services.fprintd = {
    enable = true;
    # Note: Standard libfprint supports 06cb:00df, no TOD driver needed
  };

  # Add udev rules for fingerprint access
  services.udev.packages = [ pkgs.fprintd ];

  # Enable fingerprint authentication for PAM
  security.pam.services = {
    login.fprintAuth = true;
    sudo.fprintAuth = true;
    hyprlock.fprintAuth = true;
    polkit-1.fprintAuth = true;
  };

  # Add polkit rules to allow users to enroll fingerprints
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.enroll") {
        return polkit.Result.YES;
      }
    });
    polkit.addRule(function(action, subject) {
      if (action.id == "net.reactivated.fprint.device.verify") {
        return polkit.Result.YES;
      }
    });
  '';

  # Add fprintd and fwupd tools to system packages
  environment.systemPackages = with pkgs; [
    fprintd
  ];
}
