{ pkgs, lib, config, ... }:

{
  # USB Automounting
  services.gvfs.enable = true;

  # Enable required services for auto-mounting
  services.autofs = {
    enable = true;
    debug = true;
    autoMaster = ''
      # Default mount point for USB drives
      /media  /etc/auto.usb  --timeout=60
    '';
  };

  environment.etc."auto.usb" = {
    text = ''
      # Empty automount file for USB drives
      # Actual mounting is handled by udisks2 and udev
    '';
    mode = "0644";
  };

  # Enable USB storage and SCSI kernel modules
  boot.kernelModules = [
    # USB modules
    "usb_storage"
    "uas"          # USB Attached SCSI
    "usbhid"
    "xhci_hcd"

    # SCSI modules - essential for USB mass storage
    "sd_mod"       # SCSI disk support
    "sg"           # SCSI generic support
    "sr_mod"       # SCSI CD-ROM support
    "scsi_mod"     # Core SCSI support
    "ch"           # SCSI media changer support
  ];

  # Add early module loading for USB storage
  boot.initrd.kernelModules = [
    "usb_storage"
    "uas"
    "sd_mod" 
    "scsi_mod"
  ];

  # Ensure mass storage support is included
  hardware.enableAllFirmware = true;

  # Enable USB Guard
  # services.usbguard = {
  #  enable = false;
  #  dbus.enable = true;
  #  implicitPolicyTarget = "block";
    # FIXME: set yours pref USB devices (change {id} to your trusted USB device), use `lsusb` command (from usbutils package) to get list of all connected USB devices including integrated devices like camera, bluetooth, wifi, etc. with their IDs or just disable `usbguard`
  #  rules = ''
  #    allow id {id} # device 1
  #    allow id {id} # device 2
  #  '';
  # };

  # Enable USB-specific packages
  environment.systemPackages = with pkgs; [
    usbutils
    udiskie
    exfat    # ExFAT support
    ntfs3g   # NTFS support
    dosfstools # FAT32 support
    parted
    udisks
    gvfs      # For GVFS mounts
    pmount    # Simple mount tool
    udevil   # For manual mounting with the devmon command
  ];

  # Allow users to mount devices
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        var YES = polkit.Result.YES;
        var permission = {
          "org.freedesktop.udisks2.filesystem-mount": YES,
          "org.freedesktop.udisks2.filesystem-mount-system": YES,
          "org.freedesktop.udisks2.encrypted-unlock": YES,
          "org.freedesktop.udisks2.eject-media": YES,
          "org.freedesktop.udisks2.power-off-drive": YES
        };
        if (subject.isInGroup("storage")) {
          return permission[action.id];
        }
      });
    '';
  };

  # Ensure filesystems are supported
  boot.supportedFilesystems = [ "ntfs" "exfat" "vfat" ];

  # No need for udevil service

  # Enable USB auto-mounting in file manager
  programs.thunar.plugins = lib.mkIf (config.programs.thunar.enable or false) [ pkgs.xfce.thunar-volman ];

  # Configure USB storage driver options
  boot.extraModprobeConfig = ''
    # Enable scanning of newly connected devices for SCSI
    options scsi_mod scan=sync max_luns=8
  '';

  # Add direct support for mass storage devices
  services.usbmuxd.enable = true;

  # Configure storage daemon for better device handling
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;
  };

  # Core USB hardware support
  hardware.enableRedistributableFirmware = true;
  
  # Add simplified udev rules for USB devices
  services.udev.extraRules = ''
    # Load SCSI drivers when USB storage devices are detected
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="08", ATTR{bInterfaceSubClass}=="06", \
      RUN+="${pkgs.kmod}/bin/modprobe -a sd_mod sg sr_mod"

    # Critical: Wait for devices to settle
    ACTION=="add", SUBSYSTEM=="scsi", ATTR{type}=="0", \
      RUN+="${pkgs.coreutils}/bin/sleep 2"
      
    # General rules for any USB drive
    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEMS=="block", \
      ENV{DEVTYPE}=="disk", RUN+="${pkgs.coreutils}/bin/mkdir -p /run/media/%k"

    ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEMS=="block", \
      ENV{DEVTYPE}=="partition", RUN+="${pkgs.coreutils}/bin/mkdir -p /run/media/%k"
  '';
}