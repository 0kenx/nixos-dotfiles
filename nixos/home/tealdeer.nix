{inputs, username, host, ...}: {
  programs.tealdeer = {
    enable = true;
    settings = {
      style = {
        description = {
          underline = false;
          bold = false;
          italic = true;
        };
        command_name = {
          foreground = "cyan";
          underline = false;
          bold = false;
          italic = false;
        };
        example_text = {
          foreground = "green";
          underline = false;
          bold = false;
          italic = false;
        };
        example_code = {
          foreground = "yellow";
          underline = false;
          bold = false;
          italic = true;
        };
        example_variable = {
          foreground = "blue";
          underline = false;
          bold = true;
          italic = false;
        };
      };
      display = {
        compact = false;
        use_pager = false;
      };
      updates = {
        auto_update = true;
        auto_update_interval_hours = 720;
      };
      # The directories section was empty in the original config
      # but we include it here for completeness
      directories = {};
    };
  };
}