{ pkgs, ... }:

{

  # Package overrides moved to flake.nix

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      intel-compute-runtime
      intel-media-driver    # LIBVA_DRIVER_NAME=iHD
      intel-vaapi-driver    # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
      vaapiVdpau
      libvdpau-va-gl
      mesa
      # nvidia-vaapi-driver
      # nv-codec-headers-12
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      intel-media-driver
      intel-vaapi-driver
      vaapiVdpau
      mesa
      libvdpau-va-gl
    ];
  };
}
