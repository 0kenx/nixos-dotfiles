{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    wasmedge
    # wasmer  # broken in nixpkgs 25.11 - Rust linker error
    # lunatic
    wasmi
    # wasm3
  ];
}
