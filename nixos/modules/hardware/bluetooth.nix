{ pkgs, lib, ... }:

{
  # Note: Bluetooth LE Audio (BAP) requires kernel ISO socket support.
  # The BT_ISO option is already enabled in kernel 6.18+ by default.
  # If you see "BAP requires ISO Socket" errors, your Bluetooth adapter
  # may not support LE Audio, which is fine for regular Bluetooth devices.

  # Intel BE200 Bluetooth firmware fix
  # The btintel driver fails to load zstd-compressed firmware at boot
  # This service copies uncompressed firmware and reloads the module
  systemd.services.intel-bt-firmware-reload = {
    description = "Reload Intel Bluetooth firmware";
    wantedBy = [ "bluetooth.target" ];
    before = [ "bluetooth.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      # Create firmware directory if needed
      mkdir -p /lib/firmware/intel

      # Copy uncompressed firmware
      cp ${pkgs.linux-firmware}/lib/firmware/intel/ibt-0291-0291.sfi /lib/firmware/intel/
      cp ${pkgs.linux-firmware}/lib/firmware/intel/ibt-0291-0291.ddc /lib/firmware/intel/

      # Reload bluetooth modules to pick up firmware
      ${pkgs.kmod}/bin/modprobe -r btusb btintel 2>/dev/null || true
      sleep 0.5
      ${pkgs.kmod}/bin/modprobe btusb
    '';
  };

  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    # Set input profile as headset for better compatibility
    settings = {
      General = {
        ControllerMode = "dual";
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
