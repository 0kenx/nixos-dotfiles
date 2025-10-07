{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
  };
  
  hardware.steam-hardware.enable = true;
  
  environment.systemPackages = with pkgs; [
    mangohud
    gamemode
  ];
}