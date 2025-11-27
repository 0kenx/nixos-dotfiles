# Workstation-specific hardware configuration
# Configures dual LUKS volumes with shared passphrase entry
{ config, lib, pkgs, ... }:

{
  # LUKS configuration for both root and data volumes
  # Both devices will prompt for passphrase at boot
  boot.initrd.luks.devices = {
    # Root volume (existing encrypted volume)
    crypted = {
      device = "/dev/disk/by-uuid/2d772f4b-6f40-4b94-b1d0-93962172a863";
      preLVM = true;
      allowDiscards = true;
    };

    # Data volume (/media/data)
    cryptdata = {
      device = "/dev/disk/by-uuid/2bd91d3a-85b2-4d50-ac64-1bc6e667d131";
      allowDiscards = true;
    };
  };

  # Ensure /media/data directory exists before mounting
  systemd.tmpfiles.rules = [
    "d /media/data 0755 root root -"
  ];

  # Mount the decrypted data volume
  # Use mkForce to override the definition in /etc/nixos/hardware-configuration.nix
  fileSystems."/media/data" = lib.mkForce {
    device = "/dev/mapper/cryptdata";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  # Set proper permissions on /media/data after mount
  systemd.services.media-data-permissions = {
    description = "Set permissions for /media/data";
    after = [ "media-data.mount" ];
    requires = [ "media-data.mount" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.coreutils}/bin/chown dev:users /media/data"
        "${pkgs.coreutils}/bin/chmod 775 /media/data"
      ];
      RemainAfterExit = true;
    };
  };
}
