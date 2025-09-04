{ config, lib, pkgs, ... }:

let
  winboat = pkgs.appimageTools.wrapType2 {
    pname = "winboat";
    version = "0.7.2";
    src = pkgs.fetchurl {
      url = "https://github.com/TibixDev/winboat/releases/download/v0.7.2/winboat-0.7.2.AppImage";
      sha256 = "sha256-XxUrwxw/Thv+amiv2/hGW5K12JgPtNiPdCg+7e+o788=";
    };
    extraPkgs = pkgs: with pkgs; [
      freerdp3
    ];
    extraInstallCommands = let
      appimageContents = pkgs.appimageTools.extract {
        pname = "winboat";
        version = "0.7.2";
        src = pkgs.fetchurl {
          url = "https://github.com/TibixDev/winboat/releases/download/v0.7.2/winboat-0.7.2.AppImage";
          sha256 = "sha256-XxUrwxw/Thv+amiv2/hGW5K12JgPtNiPdCg+7e+o788=";
        };
      };
    in ''
      # Install desktop entry
      mkdir -p $out/share/applications
      cat > $out/share/applications/winboat.desktop << EOF
      [Desktop Entry]
      Type=Application
      Name=WinBoat
      Comment=Run Windows apps on Linux with seamless integration
      Exec=winboat %U
      Icon=winboat
      Terminal=false
      Categories=System;Emulator;
      MimeType=
      EOF
      
      # Install icons from the extracted AppImage
      for size in 16 32 48 64 128 256 512; do
        mkdir -p $out/share/icons/hicolor/''${size}x''${size}/apps
        cp ${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/winboat.png \
           $out/share/icons/hicolor/''${size}x''${size}/apps/winboat.png
      done
    '';
  };
in
{
  config = lib.mkIf config.system.nixos-dotfiles.host.modules.enable.winboat {
    # Ensure Docker is enabled (required for WinBoat)
    virtualisation.docker.enable = true;
    
    # Ensure KVM is available
    virtualisation.libvirtd.enable = true;
    
    # Load required kernel modules for iptables
    boot.kernelModules = [ "iptable_nat" ];
    
    # Install WinBoat and dependencies
    environment.systemPackages = with pkgs; [
      winboat
      freerdp3
      docker-compose
      iptables
    ];
    
    # User group membership is already handled by virtualisation.nix
    # which adds "dev" to docker and libvirtd groups
  };
}