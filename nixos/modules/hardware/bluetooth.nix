{ pkgs, ... }:

{
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Set input profile as headset for better compatibility
    settings = {
      General = {
        ControllerMode = "dual";
        # Prevent bluez from disconnecting devices when suspend
        Enable = true;
        # Improve compatibility with some devices
        FastConnectable = true;
        # Better input device handling
        JustWorksRepairing = "always";
        Experimental = true;
      };
      Policy = {
        AutoEnable = true;
      };
    };
    # Enable HID support
    package = pkgs.bluez5-experimental;
  };

  # Add 'bluetooth' user group for permissions
  users.groups.bluetooth = {};

  # Add kernel module for HID over GATT (HOG) profile
  boot.kernelModules = [ "bluetooth_6lowpan" "btusb" "btrtl" "btintel" "btbcm" ];

  # Fix for Hyprland crashes when using bluetoothctl
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    overskride
    bluez
    bluez-tools
    blueman
  ];
}
