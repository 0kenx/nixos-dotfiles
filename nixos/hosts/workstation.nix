{config, lib, pkgs, ...}: {
  imports = [
    # Host options module
    ../modules/host-options.nix

    # System modules
    ../modules/system/time.nix
    ../modules/system/gc.nix
    ../modules/system/nix-settings.nix
    ../modules/system/linux-kernel.nix
    # ../modules/system/auto-upgrade.nix
    ../modules/system/bootloader.nix
    ../modules/system/users.nix
    ../modules/system/virtualisation.nix

    # Hardware modules
    ../modules/hardware/nvidia.nix
    ../modules/hardware/opengl.nix
    # ../modules/hardware/disable-nvidia.nix
    # ../modules/hardware/fingerprint-scanner.nix
    ../modules/hardware/sound.nix
    ../modules/hardware/usb.nix
    ../modules/hardware/keyboard.nix
    ../modules/hardware/screen.nix

    # Network modules
    ../modules/network/vpn.nix
    ../modules/network/networking.nix
    ../modules/network/openssh.nix
    # ../modules/network/mac-randomize.nix
    ../modules/network/firewall.nix
    ../modules/network/dns.nix
    ../modules/network/bluetooth.nix

    # Desktop modules
    ../modules/desktop/hyprland.nix
    ../modules/desktop/display-manager.nix
    # ../modules/desktop/gnome.nix
    ../modules/desktop/theme.nix
    ../modules/desktop/fonts.nix
    ../modules/desktop/environment-variables.nix

    # Development modules
    ../modules/dev/programming-languages.nix
    ../modules/dev/lsp.nix
    ../modules/dev/wasm.nix

    # Application modules
    ../modules/apps/multimedia.nix
    ../modules/apps/cad.nix
    ../modules/apps/terminal-utils.nix
    ../modules/apps/utils.nix
    ../modules/apps/info-fetchers.nix
    # ../modules/apps/printing.nix
    ../modules/apps/work.nix

    # Other modules
    ../modules/nixpkgs.nix
    ../modules/swap.nix
    ../modules/services.nix
    ../modules/security-services.nix
    ../modules/internationalisation.nix
    # ../modules/location.nix

    # LLM tools - both cloud and local
    ../modules/llm.nix
    ../modules/llm-local.nix  # Include local LLMs for workstation (with CUDA)
  ];

  # Configuration specific to this host
  system.nixos-dotfiles = {
    host = {
      name = "workstation";
    };

    git = {
      user = {
        name = "0kenx";
        email = "km@nxfi.app";
        signingKey = "73834AA6FB6DD8B0";
      };
      includes = [
        {
          condition = "gitdir:~/projects/";
          contents = {
            user = {
              name = "0kenx";
              email = "km@nxfi.app";
            };
          };
        }
        {
          condition = "gitdir:~/work/";
          contents = {
            user = {
              name = "Ken Miller";
              email = "ken.miller@work.com";
            };
          };
        }
      ];
    };

    hyprland = {
      monitors = [
        "HDMI-A-1,3840x2160@60,0x0,1.6"
        "DP-5,3840x2160@60,0x-1080,1.6,transform,1"
      ];
    };
  };
}
