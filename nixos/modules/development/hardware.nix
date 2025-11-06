{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # ARM embedded toolchain
    gcc-arm-embedded  # Provides gcc-arm-none-eabi for ARM Cortex-M/R bare-metal development

    # Programming and debugging tools
    openocd           # On-Chip Debugger for ARM and other architectures
    stlink            # STLink tools for STM32 programming
    dfu-util          # Device Firmware Upgrade utilities

    # Serial communication
    minicom           # Serial communication program
    screen            # Can be used for serial connections
    picocom           # Minimal dumb-terminal emulation program
  ];
}
