{ pkgs, ... }:

{
  # Hardware firmware configuration
  # Enables automatic firmware updates and provides latest firmware for hardware devices

  # Enable redistributable firmware (includes WiFi, Bluetooth, graphics firmware)
  # This already includes linux-firmware package
  hardware.enableRedistributableFirmware = true;

  # Note: hardware.firmware is not needed as enableRedistributableFirmware already
  # includes linux-firmware. Adding it explicitly can cause version conflicts.

  # Enable firmware update daemon (fwupd is already enabled in services.nix)
  # This provides automatic firmware updates for supported devices
}
