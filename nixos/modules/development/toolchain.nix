{ pkgs, pkgs-unstable, ... }:

let
  # Apalache model checker (not in nixpkgs — fetch pre-built release and wrap)
  apalacheVersion = "0.52.2";
  apalache = pkgs.stdenv.mkDerivation {
    pname = "apalache";
    version = apalacheVersion;

    src = pkgs.fetchurl {
      url = "https://github.com/apalache-mc/apalache/releases/download/v${apalacheVersion}/apalache-${apalacheVersion}.tgz";
      sha256 = "e0ebea7e45c8f99df8d92f2755101dda84ab71df06d1ec3a21955d3b53a886e2";
    };

    nativeBuildInputs = [ pkgs.makeWrapper ];
    buildInputs = [ pkgs.jdk17_headless ];

    dontConfigure = true;
    dontBuild = true;

    unpackPhase = ''
      mkdir -p src
      tar xzf $src -C src --strip-components=1
    '';

    installPhase = ''
      mkdir -p $out/share/apalache $out/bin
      cp -r src/lib $out/share/apalache/
      cp -r src/bin $out/share/apalache/

      makeWrapper $out/share/apalache/bin/apalache-mc $out/bin/apalache-mc \
        --set JAVA_HOME "${pkgs.jdk17_headless}" \
        --prefix PATH : "${pkgs.jdk17_headless}/bin"
    '';
  };
in
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

    # USB/HID device libraries
    libusb1
    hidapi
    systemd.dev  # provides libudev

    # Language runtimes
    go
    (python312.withPackages(ps: with ps; [ pygobject3 gobject-introspection pyqt6-sip tkinter]))
    python312Packages.uv
    nodejs_22
    bun
    lua
    zig
    jdk11

    # Formal verification
    quint
    apalache
    z3
    tlaplus         # TLA+ tools (TLC model checker, SANY parser, PlusCal translator)

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