{ pkgs, ... }:

{
  # Setup Env Variables
  environment.variables = {
    JDK_PATH = "${pkgs.jdk11}/";
    NODEJS_PATH = "${pkgs.nodePackages_latest.nodejs}/";
    TLA2TOOLS_JAR = "${pkgs.tlaplus}/share/java/tla2tools.jar";
    NIXOS_OZONE_WL = "1"; # Enable Wayland for Electron/CEF apps
    CHROMIUM_PASSWORD_STORE = "gnome-libsecret"; # Use gnome-keyring for Chromium apps
    BROWSER = "google-chrome-stable"; # Default browser for command-line tools
  };
}
