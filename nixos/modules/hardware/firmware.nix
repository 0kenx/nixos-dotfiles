{ pkgs, ... }:

{
  # Hardware firmware configuration
  # Enables automatic firmware updates and provides latest firmware for hardware devices

  # Enable redistributable firmware (includes WiFi, Bluetooth, graphics firmware)
  hardware.enableRedistributableFirmware = true;

  # Enable firmware update daemon (fwupd is already enabled in services.nix)
  # This provides automatic firmware updates for supported devices

  # Add latest firmware packages
  hardware.firmware = with pkgs; [
    linux-firmware  # Latest Linux firmware (includes iwlwifi updates)
  ];

  # Specific WiFi firmware fixes for Intel BE200
  # The BE200 has known stability issues with WiFi 7 - already addressed in kernel params
  # but we ensure latest firmware is available
}
