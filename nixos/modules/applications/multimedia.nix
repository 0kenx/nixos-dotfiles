{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    feh
    nsxiv
    mpv
    gimp
    rhythmbox
  ];
}
