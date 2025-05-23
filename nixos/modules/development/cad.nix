{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    freecad-wayland
    orca-slicer
    # Temporarily disable bambu-studio due to CUDA build issues
    # bambu-studio
  ];
}
