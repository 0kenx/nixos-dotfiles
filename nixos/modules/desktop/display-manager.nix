{ pkgs, ... }:

{
  # Enable Display Manager
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet \
          --time --time-format '%I:%M %p | %a • %h | %F' \
          --cmd 'uwsm start hyprland'";
        user    = "greeter";
      };
    };
  };

  users.users.greeter = {
    isNormalUser = false;
    description  = "greetd greeter user";
    extraGroups  = [ "video" "audio" ];
    linger        = true;
  };

  # Set cursor theme for greeter session
  environment.etc."greetd/env".text = ''
    export XCURSOR_THEME=Catppuccin-Macchiato-Sapphire-Cursors
    export XCURSOR_SIZE=24
    export HYPRCURSOR_THEME=Catppuccin-Macchiato-Sapphire-Cursors
    export HYPRCURSOR_SIZE=24
  '';

  # Set environment variables for greetd
  systemd.services.greetd.environment = {
    XCURSOR_THEME = "Catppuccin-Macchiato-Sapphire-Cursors";
    XCURSOR_SIZE = "24";
    HYPRCURSOR_THEME = "Catppuccin-Macchiato-Sapphire-Cursors";
    HYPRCURSOR_SIZE = "24";
  };

  environment.systemPackages = with pkgs; [
    greetd.tuigreet
  ];
}
