{ pkgs, lib, config, ... }:

{
  # Use a single, consistent USB automounting solution
  # Disable autofs and devmon which conflict with udiskie
  services.gvfs.enable = true;  # Keep GVFS for Thunar integration

  # Disable autofs - conflicting with udiskie
  services.autofs.enable = false;

  # Disable udevil/devmon - conflicting with udiskie
  services.devmon.enable = false;

  # Keep essential USB storage kernel modules
  # but avoid redundant loading
  boot.kernelModules = [
    # USB modules - core essentials only
    "usb_storage"
    "uas"          # USB Attached SCSI
    "usbhid"

    # SCSI modules - only the essential ones
    "sd_mod"       # SCSI disk support
    "sr_mod"       # SCSI CD-ROM support
    "scsi_mod"     # Core SCSI support

    # USB Serial device support
    "usbserial"    # Generic USB serial driver
    "ftdi_sio"     # FTDI USB serial adapters
    "pl2303"       # Prolific PL2303 USB serial adapters
    "cp210x"       # Silicon Labs CP210x USB to UART Bridge
    "ch341"        # WinChipHead CH341 USB serial adapters
    "cdc_acm"      # USB Abstract Control Model for modems and serial adapters
  ];

  # Add early module loading for USB storage
  # Keeping only essential modules for boot
  boot.initrd.kernelModules = [
    "usb_storage"
    "sd_mod"
  ];

  # Ensure mass storage support is included
  hardware.enableAllFirmware = true;

  # Enable USB-specific packages
  environment.systemPackages = with pkgs; [
    usbutils
    udiskie      # Single automounting solution
    exfat        # ExFAT support
    ntfs3g       # NTFS support
    dosfstools   # FAT32 support
    parted
    udisks
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

  # Enable USB auto-mounting in file manager if Thunar is enabled
  programs.thunar.plugins = lib.mkIf (config.programs.thunar.enable or false) [ pkgs.xfce.thunar-volman ];

  # Optimize USB storage driver options
  boot.extraModprobeConfig = ''
    # Configure SCSI module with modest values to reduce CPU usage
    options scsi_mod scan=async max_luns=4
  '';

  # Configure storage daemon - essential for automounting
  services.udisks2 = {
    enable = true;
    mountOnMedia = true;  # Mount devices in /media instead of /run/media
  };

  # Core USB hardware support
  hardware.enableRedistributableFirmware = true;

  # Enable Ledger hardware wallet support
  hardware.ledger.enable = true;

  # Use a more efficient udev rule that only loads modules when needed
  # and doesn't trigger on every USB event
  services.udev.extraRules = ''
    # Load SCSI drivers only when mass storage devices are detected
    # Using lower priority to reduce impact on system performance
    ACTION=="add", SUBSYSTEM=="usb", ATTR{bInterfaceClass}=="08", ATTR{bInterfaceSubClass}=="06", \
      ATTR{authorized}=="1", RUN+="${pkgs.systemd}/bin/systemd-run --no-block --property=Nice=10 ${pkgs.kmod}/bin/modprobe -a sd_mod"

    # USB serial device permissions
    KERNEL=="ttyUSB[0-9]*", MODE="0666", GROUP="serial"
    KERNEL=="ttyACM[0-9]*", MODE="0666", GROUP="serial"
    KERNEL=="ttyS[0-9]*", MODE="0666", GROUP="serial"

    # Common USB serial adapters: FTDI
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0403", MODE="0666", GROUP="serial"
    # Prolific
    SUBSYSTEM=="usb", ATTRS{idVendor}=="067b", MODE="0666", GROUP="serial"
    # Silicon Labs
    SUBSYSTEM=="usb", ATTRS{idVendor}=="10c4", MODE="0666", GROUP="serial"
    # CH340/CH341
    SUBSYSTEM=="usb", ATTRS{idVendor}=="1a86", MODE="0666", GROUP="serial"

    # STMicroelectronics STM32 DFU Mode for WebUSB access
    SUBSYSTEM=="usb", ATTR{idVendor}=="0483", ATTR{idProduct}=="df11", MODE="0666", GROUP="plugdev", TAG+="uaccess"
  '';

  # Add serial group for serial port access
  # Users should be added to this group manually in their user configuration
  users.groups.serial = {};
}