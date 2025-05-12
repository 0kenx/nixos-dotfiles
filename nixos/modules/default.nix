{ ... }:

{
  imports = [
    # Core system modules
    ./system/time.nix
    ./system/gc.nix
    ./system/nix-settings.nix
    ./system/linux-kernel.nix
    # ./system/auto-upgrade.nix
    ./system/bootloader.nix
    ./system/users.nix
    ./system/virtualisation.nix
    
    # Hardware-related modules
    ./hardware/nvidia.nix
    ./hardware/opengl.nix
    # ./hardware/disable-nvidia.nix
    # ./hardware/fingerprint-scanner.nix
    ./hardware/sound.nix
    ./hardware/usb.nix
    ./hardware/keyboard.nix
    ./hardware/screen.nix
    ./hardware/yubikey.nix
    
    # Network-related modules
    ./network/vpn.nix
    ./network/networking.nix
    ./network/openssh.nix
    # ./network/mac-randomize.nix
    ./network/firewall.nix
    ./network/dns.nix
    ./network/bluetooth.nix
    
    # Desktop environment
    ./desktop/hyprland.nix
    ./desktop/display-manager.nix
    # ./desktop/gnome.nix
    ./desktop/theme.nix
    ./desktop/fonts.nix
    ./desktop/environment-variables.nix
    
    # Development tools
    ./dev/programming-languages.nix
    ./dev/lsp.nix
    ./dev/wasm.nix
    
    # Applications
    ./apps/multimedia.nix
    ./apps/cad.nix
    ./apps/terminal-utils.nix
    ./apps/utils.nix
    ./apps/info-fetchers.nix
    # ./apps/printing.nix
    ./apps/work.nix
    
    # Other modules
    ./nixpkgs.nix
    ./swap.nix
    ./services.nix
    ./security-services.nix
    ./internationalisation.nix
    # ./location.nix
    
    # Cloud LLMs are enabled in the base modules
    ./llm.nix
    
    # Note: llm-local.nix is selectively imported by host configs
  ];
}