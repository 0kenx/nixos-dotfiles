{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    devenv
    go
    (python312Full.withPackages(ps: with ps; [ pygobject3 gobject-introspection pyqt6-sip]))
    python312Packages.uv
    nodejs_22
    bun
    lua
    zig
    numbat

    postgresql
    beekeeper-studio
  ];
}
