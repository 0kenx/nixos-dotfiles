{pkgs, ...}: {
  services.dunst = {
    enable = true;
    
    settings = {
      global = {
        # Appearance
        frame_color = "#cad3f5";
        separator_color = "frame";
        font = "JetBrains Mono Regular 11";
        corner_radius = 10;
        offset = "5x5";
        origin = "top-right";
        notification_limit = 8;
        gap_size = 7;
        frame_width = 2;
        width = 300;
        height = 100;
        
        # Behavior
        monitor = 0;
        follow = "none";
        indicate_hidden = true;
        transparency = 0;
        separator_height = 2;
        padding = 8;
        horizontal_padding = 8;
        text_icon_padding = 0;
        
        # Text
        line_height = 0;
        markup = "full";
        format = "<b>%s</b>\\n%b";
        alignment = "left";
        vertical_alignment = "center";
        show_age_threshold = 60;
        ellipsize = "middle";
        ignore_newline = false;
        stack_duplicates = true;
        hide_duplicate_count = false;
        show_indicators = true;
        
        # Icons
        icon_position = "left";
        min_icon_size = 0;
        max_icon_size = 32;
        
        # History
        sticky_history = true;
        history_length = 20;
        
        # Misc
        always_run_script = true;
        title = "Dunst";
        class = "Dunst";
        force_xwayland = false;
        force_xinerama = false;
        mouse_left_click = "close_current";
        mouse_middle_click = "do_action, close_current";
        mouse_right_click = "close_all";
      };
      
      urgency_low = {
        background = "#24273A";
        foreground = "#CAD3F5";
        timeout = 10;
      };
      
      urgency_normal = {
        background = "#24273A";
        foreground = "#CAD3F5";
        timeout = 10;
      };
      
      urgency_critical = {
        background = "#24273A";
        foreground = "#CAD3F5";
        frame_color = "#F5A97F";
        timeout = 0;
      };
    };
  };
}