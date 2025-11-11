{ pkgs, lib, ... }:

{
  # Fingerprint scanner (Synaptics FS7605 - Device ID 06cb:00df)
  # DISABLED: This device has a known regression in libfprint 1.92.0+ (NixOS ships 1.94.9)
  # Support existed in libfprint 1.90.2-1.90.7 but was broken in later versions.
  # See: https://bugs.launchpad.net/ubuntu/+source/libfprint/+bug/1913895
  #
  # To fix this would require downgrading both libfprint and fprintd to 1.90.x versions,
  # which creates build compatibility issues with modern NixOS tooling.
  #
  # Possible solutions:
  # - Wait for upstream libfprint to fix the regression
  # - Report to NixOS: https://github.com/NixOS/nixpkgs/issues
  # - Look for community flakes with working 1.90.x versions

  services.fprintd = {
    enable = false;  # Disabled due to device regression
  };

  # Add udev rules for fingerprint access (if re-enabled)
  # services.udev.packages = [ pkgs.fprintd ];

  # Fingerprint PAM authentication (disabled while fprintd is disabled)
  # security.pam.services = {
  #   login.fprintAuth = true;
  #   sudo.fprintAuth = true;
  #   hyprlock.fprintAuth = true;
  #   polkit-1.fprintAuth = true;
  # };

  # Polkit rules to allow users to enroll fingerprints (disabled)
  # security.polkit.extraConfig = ''
  #   polkit.addRule(function(action, subject) {
  #     if (action.id == "net.reactivated.fprint.device.enroll") {
  #       return polkit.Result.YES;
  #     }
  #   });
  #   polkit.addRule(function(action, subject) {
  #     if (action.id == "net.reactivated.fprint.device.verify") {
  #       return polkit.Result.YES;
  #     }
  #   });
  # '';

  # fprintd tools (disabled)
  # environment.systemPackages = [ pkgs.fprintd ];
}
