{ pkgs, ... }:

let
  # Wrap clash-nyanpasu with proper Wayland/EGL environment variables
  clash-nyanpasu-wrapped = pkgs.symlinkJoin {
    name = "clash-nyanpasu";
    paths = [ pkgs.clash-nyanpasu ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/clash-nyanpasu \
        --set WEBKIT_DISABLE_DMABUF_RENDERER 1 \
        --set WEBKIT_DISABLE_COMPOSITING_MODE 1
    '';
  };
in
{
  environment.systemPackages = with pkgs; [
    tor-browser
    clash-nyanpasu-wrapped  # Clash GUI client (wrapped for Wayland compatibility)
  ];
}
