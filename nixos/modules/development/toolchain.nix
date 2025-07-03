{ pkgs, pkgs-unstable, ... }:

{
  environment.systemPackages = with pkgs; [
    # Build tools
    mold
    gcc
    clang
    lld
    musl
    gnumake
    cmake
    
    # Language runtimes
    go
    (python312Full.withPackages(ps: with ps; [ pygobject3 gobject-introspection pyqt6-sip]))
    python312Packages.uv
    nodejs_22
    bun
    lua
    zig
    jdk11
    
    # Other tools
    numbat
    pkgs-unstable.devenv
  ];
  
  # Configure devenv and its cachix
  nix.extraOptions = ''
    # Setup devenv cachix
    substituters = https://cache.nixos.org https://devenv.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=
  '';
}