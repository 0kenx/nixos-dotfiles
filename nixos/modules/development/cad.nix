{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    freecad-wayland
    orca-slicer
    bambu-studio
  ];
}
