{ pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    tor-browser
    clash-nyanpasu  # Clash GUI client based on tauri
  ];
}
