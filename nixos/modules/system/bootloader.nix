{ pkgs, config, ... }:

{
  # Bootloader.
  # boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  # boot.loader.timeout = 2;

  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };

  # boot.kernelParams = [ "processor.max_cstate=4" "amd_iomu=soft" "idle=nomwait" ];

  # Enable systemd in initrd for Bluetooth support at LUKS prompt
  boot.initrd.systemd.enable = true;

  # Add Bluetooth kernel modules to initrd
  boot.initrd.kernelModules = [ "btusb" "btrtl" "btintel" "btbcm" "btmtk" "bluetooth" "uhid" ];

  # Include Bluetooth firmware in initrd
  hardware.firmware = [ pkgs.linux-firmware ];
  hardware.enableAllFirmware = true;

  # Copy Bluetooth config to initrd
  boot.initrd.systemd.contents."/etc/bluetooth".source = "${config.hardware.bluetooth.package}/etc/bluetooth";

  # boot.initrd.verbose = false;
  # boot.initrd.availableKernelModules = [ "i915" ];
  # boot.consoleLogLevel = 3;
  # boot.plymouth = {
  #   enable = true;
    # font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
  #   themePackages = [ pkgs.catppuccin-plymouth ];
  #   theme = "catppuccin-macchiato";
  # };
}
