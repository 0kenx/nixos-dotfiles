{ pkgs, ... }:
{
  home.packages = (with pkgs; [ rofi-wayland ]);

  xdg.configFile."rofi/theme.rasi".text = ''
    * {
      bg-col:  #24273aaa;
      bg-col-light: #24273aaa;
      border-col: #24273aaa;
      selected-col: #24273aaa;
      blue: #8aadf4aa;
      fg-col: #cad3f5aa;
      fg-col2: #ed8796aa;
      grey: #6e738daa;
      sapphire: #7dc4e4aa;

      width: 600;
      border-radius: 15px;
    }
  '';

  xdg.configFile."rofi/config.rasi".text = ''
    configuration{
      modi: "drun,window,run";
      icon-theme: "Numix-Circle";
      font: "JetBrains Mono Regular 13";
      show-icons: true;
      terminal: "kitty";
      drun-display-format: "{name}";
      location: 0;
      disable-history: false;
      hide-scrollbar: true;
      hover-select: true;
      ma-select-entry: "MousePrimary";
      ma-accept-entry: "!MousePrimary";
      display-drun: " ";
      display-run: " ";
      display-filebrowser: "  ";
      display-window: "  ";
      sidebar-mode: true;
      border-radius: 10;
    }

    @theme "theme"

    window {
      height: 20em;
      width: 35em;
      spacing: 0em;
      padding: 0em;
      border: 2px;
      border-color: @sapphire;
      background-color: @bg-col;
    }

    mainbox {
      spacing: 0em;
      padding: 0em;
      background-color: transparent;
      orientation: vertical;
      children: [inputbar, listbox];
    }

    inputbar {
      children: [prompt,entry];
      background-color: @bg-col;
      border-radius: 5px;
      padding: 2em;
      spacing: 0em;
    }

    prompt {
      str: "  ";
      expand: false;
      background-color: @bg-col;
      padding: 0.5em 0.2em 0em 0em;
      text-color: @fg-col;
      border-radius: 2em 0em 0em 2em;
    }

    entry {
      padding: 0.5em;
      spacing: 0.5em;
      border-radius: 0em 2em 2em 0em;
      // margin: 20px 0px 0px 10px;
      text-color: @fg-col;
      background-color: @bg-col;
      cursor: text;
      placeholder: "Search";
      // placeholder-color: inherit;
    }

    listbox {
      padding:                     0em;
      spacing:                     0em;
      orientation:                 horizontal;
      children:                    [ "listview" , "mode-switcher" ];
      background-color:            transparent;
    }

    listview {
      padding:                     1.5em;
      spacing:                     0.5em;
      enabled:                     true;
      columns:                     2;
      lines:                       3;
      cycle:                       true;
      dynamic:                     true;
      scrollbar:                   false;
      layout:                      vertical;
      reverse:                     false;
      fixed-height:                true;
      fixed-columns:               true;
      cursor:                      "default";
      background-color:            transparent;
      text-color:                  @fg-col;
    }

    element {
      spacing: 0em;
      padding: 0.5em;
      cursor: pointer;
      background-color: transparent;
      text-color: @fg-col  ;
    }

    element-icon {
      size: 25px;
      background-color: transparent;
      text-color: inherit;
    }

    element-text {
      background-color: transparent;
      text-color: inherit;
    }

    element selected {
      background-color:  @selected-col ;
      text-color: @sapphire  ;
    }

    mode-switcher {
      orientation: vertical;
      width: 6em;
      padding: 0em;
      spacing: 0em;
      border-radius: 0em;
      background-color: transparent;
      text-color: inherit;
    }

    button {
      padding: 10px;
      background-color: @bg-col-light;
      text-color: @grey;
      vertical-align: 0.5;
      horizontal-align: 0.5;
    }

    button selected {
      background-color: @bg-col;
      text-color: @blue;
    }

    message {
      background-color: @bg-col-light;
      margin: 2px;
      padding: 2px;
      border-radius: 5px;
    }

    textbox {
      padding: 6px;
      margin: 20px 0px 0px 20px;
      text-color: @blue;
      background-color: @bg-col-light;
    }

  '';
}

