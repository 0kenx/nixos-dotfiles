{ pkgs,  ... }:

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

  # boot.initrd.enable = true;
  # boot.initrd.verbose = false;
  # boot.initrd.systemd.enable = true;
  # boot.initrd.availableKernelModules = [ "i915" ];
  # boot.initrd.kernelModules          = [ "i915" ];
  # boot.consoleLogLevel = 3;
  # boot.plymouth = {
  #   enable = true;
    # font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
  #   themePackages = [ pkgs.catppuccin-plymouth ];
  #   theme = "catppuccin-macchiato";
  # };
}
