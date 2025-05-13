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
        AutoEnable = true;
        # Improve compatibility with some devices
        FastConnectable = true;
        # Better input device handling
        JustWorksRepairing = "always";
        Experimental = true;
      };
    };
  };

  # Fix for Hyprland crashes when using bluetoothctl
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    overskride
    bluez
    bluez-tools
    blueman
  ];
}
