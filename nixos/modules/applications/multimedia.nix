{ config, pkgs, ... }:

{
  # OBS Studio with virtual camera support
  programs.obs-studio = {
    enable = true;
    enableVirtualCamera = true;
  };

  # Explicitly load v4l2loopback kernel module for OBS virtual camera
  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  boot.kernelModules = [ "v4l2loopback" ];

  # Configure v4l2loopback module parameters
  boot.extraModprobeConfig = ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';

  environment.systemPackages = with pkgs; [
    feh
    nsxiv
    mpv
    gimp
    rhythmbox
    audacity
    kdePackages.kdenlive
  ];
}
