{inputs, username, host, pkgs, ...}: {
  # Ensure swappy is installed
  home.packages = with pkgs; [
    swappy
  ];
  
  # Create the swappy configuration
  xdg.configFile."swappy/config".text = ''
    [Default]
    save_dir=$HOME/Pictures/Edits
    save_filename_format=swappy-%Y%m%d-%H%M%S.png
    show_panel=false
    line_size=5
    text_size=20
    text_font=sans-serif
    paint_mode=brush
    early_exit=false
    fill_shape=false
  '';
  
  # Ensure the save directory exists
  home.file."Pictures/Edits/.keep".text = "";
}