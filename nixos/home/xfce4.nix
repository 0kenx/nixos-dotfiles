{inputs, username, host, pkgs, ...}: {
  # Install xfce4 related packages if needed
  home.packages = with pkgs; [
    xfce.xfconf # For Thunar configuration
  ];
  
  # Configure xfce4 components
  xdg.configFile = {
    # Thunar configuration via xfconf
    "xfce4/xfconf/xfce-perchannel-xml/thunar.xml".text = ''
      <?xml version="1.0" encoding="UTF-8"?>
      
      <channel name="thunar" version="1.0">
        <property name="last-view" type="string" value="ThunarIconView"/>
        <property name="last-icon-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_100_PERCENT"/>
        <property name="last-show-hidden" type="bool" value="true"/>
        <property name="last-window-maximized" type="bool" value="true"/>
        <property name="misc-single-click" type="bool" value="false"/>
        <property name="misc-text-beside-icons" type="bool" value="false"/>
        <property name="last-separator-position" type="int" value="170"/>
        <property name="last-details-view-zoom-level" type="string" value="THUNAR_ZOOM_LEVEL_38_PERCENT"/>
        <property name="last-details-view-visible-columns" type="string" value="THUNAR_COLUMN_DATE_MODIFIED,THUNAR_COLUMN_NAME,THUNAR_COLUMN_SIZE,THUNAR_COLUMN_TYPE"/>
        <property name="last-details-view-column-widths" type="string" value="50,50,147,50,50,368,50,50,969,50,50,89,50,179"/>
      </channel>
    '';
  };
}