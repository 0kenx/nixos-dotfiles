{ pkgs, lib, ... }:

{
  # Enable networking
  networking.hostName = lib.mkDefault "nixos"; # Define your hostname, can be overridden by host configs
  
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  # networking.networkmanager.wifi.backend = "iwd";

  # Disable wait-online service to speed up boot
  systemd.services.NetworkManager-wait-online.enable = false;

  networking.wireless.iwd = {
    enable = true;
    settings = {
      General = {
        EnableNetworkConfiguration = true;
        RoamRetryInterval = 15;
        RoamThreshold = -70;
        AutoConnect = true;
      };
      Network = {
        EnableIPv6 = true;
        RoutePriorityOffset = 300;
      };
      Scan = {
        DisablePeriodicScan = false;
        DisableRoamingScan = false;
        InitialPeriodicScanInterval = 10;
      };
      Settings = {
        AlwaysReconnect = true;
      };
    };
  };

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  environment.systemPackages = with pkgs; [
    iwgtk
    impala
  ];
}