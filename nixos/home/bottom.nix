{inputs, username, host, ...}: {
  programs.bottom = {
    enable = true;
    settings = {
      colors = {
        table_header_color = "#f4dbd6";
        all_cpu_color = "#f4dbd6";
        avg_cpu_color = "#ee99a0";
        cpu_core_colors = [
          "#ed8796"
          "#f5a97f"
          "#eed49f"
          "#a6da95"
          "#7dc4e4"
          "#c6a0f6"
        ];
        ram_color = "#a6da95";
        swap_color = "#f5a97f";
        rx_color = "#a6da95";
        tx_color = "#ed8796";
        widget_title_color = "#f0c6c6";
        border_color = "#5b6078";
        highlighted_border_color = "#f5bde6";
        text_color = "#cad3f5";
        graph_color = "#a5adcb";
        cursor_color = "#f5bde6";
        selected_text_color = "#181926";
        selected_bg_color = "#c6a0f6";
        high_battery_color = "#a6da95";
        medium_battery_color = "#eed49f";
        low_battery_color = "#ed8796";
        gpu_core_colors = [
          "#7dc4e4"
          "#c6a0f6"
          "#ed8796"
          "#f5a97f"
          "#eed49f"
          "#a6da95"
        ];
        arc_color = "#91d7e3";
      };
      
      # Use default layout and flags (commented out options)
      # Any other configuration options can be added here if needed
      # For example:
      # flags = {
      #   temperature_type = "c";
      #   rate = 1000;
      # };
    };
  };
}