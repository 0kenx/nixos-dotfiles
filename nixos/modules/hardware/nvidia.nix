{ config, lib, pkgs, ... }:

{
  # Use modesetting for display, nvidia for compute
  services.xserver.videoDrivers = ["modesetting" "nvidia"];

  # Enable access to nvidia from containers (Docker, Podman)
  # This handles GPU presence gracefully - works with or without GPU
  hardware.nvidia-container-toolkit.enable = true;
  # Suppress assertion since we're using modesetting for display, not nvidia
  hardware.nvidia-container-toolkit.mount-nvidia-executables = true;
  hardware.nvidia-container-toolkit.suppressNvidiaDriverAssertion = true;

  # Make NVIDIA driver packages available for compute
  # These load on-demand when hardware is detected
  hardware.nvidia = {

    # Modesetting for kernel module
    modesetting.enable = true;

    # Don't enable nvidiaPersistenced - it fails without GPU present
    # nvidiaPersistenced = true;

    # Disable power management features that require GPU presence
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    dynamicBoost.enable = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    open = true;

    # Enable the Nvidia settings menu (only useful when GPU present)
    nvidiaSettings = true;

    # Use the latest production driver (currently 570.195.03)
    # This is compatible with kernel 6.17 and more stable than beta drivers
    package = config.boot.kernelPackages.nvidiaPackages.production;

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
