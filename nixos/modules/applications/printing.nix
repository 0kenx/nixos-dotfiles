{ config, pkgs, ... }:

{
  # Enable CUPS to print documents
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      hplip
      brlaser
      brgenml1lpr
      brgenml1cupswrapper
      cups-filters
      cups-brother-dcpl3550cdw
      brscan4
      brscan5
    ];
  };

  # Enable Avahi for printer discovery
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Install printing-related utilities
  environment.systemPackages = with pkgs; [
    system-config-printer
    cups-pk-helper
    cups
  ];
}
