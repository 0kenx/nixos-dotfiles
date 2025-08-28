{ config, lib, pkgs, ... }:
  let
  # https://github.com/NVIDIA/open-gpu-kernel-modules/issues/840
  gpl_symbols_linux_615_patch = pkgs.fetchpatch {
    url = "https://github.com/CachyOS/kernel-patches/raw/914aea4298e3744beddad09f3d2773d71839b182/6.15/misc/nvidia/0003-Workaround-nv_vm_flags_-calling-GPL-only-code.patch";
    hash = "sha256-YOTAvONchPPSVDP9eJ9236pAPtxYK5nAePNtm2dlvb4=";
    stripLen = 1;
    extraPrefix = "kernel/";
  };
in
{
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  # Enable access to nvidia from containers (Docker, Podman)
  hardware.nvidia-container-toolkit.enable = true;

  hardware.nvidia = {

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Dynamic Boost. It is a technology found in NVIDIA Max-Q design laptops with RTX GPUs.
    # It intelligently and automatically shifts power between
    # the CPU and GPU in real-time based on the workload of your game or application.
    # dynamicBoost.enable = lib.mkForce true;
    dynamicBoost.enable = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu,
  	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.latest;
    # Using the latest stable driver package from nixpkgs
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    
    # Override to use specific NVIDIA driver version 575.64.03
    package = config.boot.kernelPackages.nvidiaPackages.mkDriver {
      version = "575.64.03";
      sha256_64bit = "sha256-S7eqhgBLLtKZx9QwoGIsXJAyfOOspPbppTHUxB06DKA=";
      sha256_aarch64 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="; # Not needed for x86_64
      openSha256 = "sha256-SAl1+XH4ghz8iix95hcuJ/EVqt6ylyzFAao0mLeMmMI=";
      settingsSha256 = "sha256-o8rPAi/tohvHXcBV+ZwiApEQoq+ZLhCMyHzMxIADauI=";
      persistencedSha256 = "sha256-QUa7T58+kfMbfWY/fnyaRtBhzsVhe8qNOSaF8/KRLa0=";
    };

    # Nvidia Optimus PRIME. It is a technology developed by Nvidia to optimize
    # the power consumption and performance of laptops equipped with their GPUs.
    # It seamlessly switches between the integrated graphics,
    # usually from Intel, for lightweight tasks to save power,
    # and the discrete Nvidia GPU for performance-intensive tasks.
    # prime = {
    #		offload = {
    #			enable = true;
    #			enableOffloadCmd = true;
    #		};

  		# FIXME: Change the following values to the correct Bus ID values for your system!
      # More on "https://wiki.nixos.org/wiki/Nvidia#Configuring_Optimus_PRIME:_Bus_ID_Values_(Mandatory)"
    #		nvidiaBusId = "PCI:2:0:0";
    #		intelBusId = "PCI:0:2:0";
    #	};
  };

  # NixOS specialization named 'nvidia-sync'. Provides the ability
  # to switch the Nvidia Optimus Prime profile
  # to sync mode during the boot process, enhancing performance.
  # specialisation = {
  #   nvidia-sync.configuration = {
  #     system.nixos.tags = [ "nvidia-sync" ];
  #     hardware.nvidia = {
  #       powerManagement.finegrained = lib.mkForce false;

  #       prime.offload.enable = lib.mkForce false;
  #       prime.offload.enableOffloadCmd = lib.mkForce false;

  #       prime.sync.enable = lib.mkForce true;
  #      };
  #    };
  # };
}
