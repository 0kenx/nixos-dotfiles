{inputs, username, host, pkgs, ...}: {
  # Install wlogout
  home.packages = with pkgs; [
    wlogout
  ];
  
  # Configure wlogout
  xdg.configFile = {
    # Layout configuration
    "wlogout/layout".text = ''
      {
          "label" : "lock",
          "action" : "hyprlock",
          "text" : "Lock",
          "keybind" : "l"
      }
      {
          "label" : "hibernate",
          "action" : "systemctl hibernate",
          "text" : "Hibernate",
          "keybind" : "h"
      }
      {
          "label" : "logout",
          "action" : "loginctl terminate-user $USER",
          "text" : "Logout",
          "keybind" : "e"
      }
      {
          "label" : "shutdown",
          "action" : "systemctl poweroff",
          "text" : "Shutdown",
          "keybind" : "s"
      }
      {
          "label" : "suspend",
          "action" : "systemctl suspend",
          "text" : "Suspend",
          "keybind" : "u"
      }
      {
          "label" : "reboot",
          "action" : "systemctl reboot",
          "text" : "Reboot",
          "keybind" : "r"
      }
    '';
    
    # Styles
    "wlogout/style.css".text = ''
      * {
        background-image: none;
      }
      
      window {
        background-color: rgba(36, 39, 58, 0.9);
      }
      
      button {
        margin: 8px;
        color: #cad3f5;
        background-color: #363a4f;
        border-style: solid;
        border-width: 2px;
        background-repeat: no-repeat;
        background-position: center;
        background-size: 25%;
      }
      
      button:active,
      button:focus,
      button:hover {
        color: #8bd5ca;
        background-color: #24273a;
        outline-style: none;
      }
      
      #lock {
        background-image: image(url("icons/lock.png"));
      }
      
      #logout {
        background-image: image(url("icons/logout.png"));
      }
      
      #suspend {
        background-image: image(url("icons/suspend.png"));
      }
      
      #hibernate {
        background-image: image(url("icons/hibernate.png"));
      }
      
      #shutdown {
        background-image: image(url("icons/shutdown.png"));
      }
      
      #reboot {
        background-image: image(url("icons/reboot.png"));
      }
    '';
    
    # Icons - we'll reference the package icons instead
    # This ensures we don't rely on external files
    # Note: In a real-world scenario, you would include icons from pkgs or find their default paths
    # For now, we'll leave this section relying on wlogout's default icons
    # Wlogout will typically find these icons in its built-in theme directories
  };
}