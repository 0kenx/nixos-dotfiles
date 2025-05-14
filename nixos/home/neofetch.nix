{pkgs, lib, ...}: {
  # Add neofetch to home packages
  home.packages = with pkgs; [
    neofetch
  ];

  # Create a custom neofetch config
  xdg.configFile."neofetch/config.conf".text = ''
    # See this wiki page for more info:
    # https://github.com/dylanaraps/neofetch/wiki/Customizing-Info
    print_info() {
        info title
        info underline

        # Colorized info fields
        info "$(color 1) OS" distro
        info "$(color 2)󰌢 Host" model
        info "$(color 3) Kernel" kernel
        info "$(color 4)↑ Uptime" uptime
        info "$(color 5) Packages" packages
        info "$(color 6) Shell" shell
        info "$(color 7)󰹑 Resolution" resolution
        info "$(color 8)󰨇 DE" de
        info "$(color 9)󰭠 WM" wm
        info "$(color 10)󱕕 Theme" theme
        info "$(color 11)󱁹 Icons" icons
        info "$(color 12) Font" font
        info "$(color 13) Terminal Font" term_font
        info "$(color 14) Terminal" term
        info "$(color 6) CPU" cpu
        info "$(color 2) GPU" gpu
        info "$(color 3)󰃽 GPU Driver" gpu_driver
        info "$(color 4) Memory" memory
        info "$(color 5)󰋊 Disk" disk
        info "$(color 6)󰂀 Battery" battery

        info cols
    }

    # Use ASCII art with the Linux penguin
    image_backend="ascii"
    ascii_distro="linux"

    # Bold ASCII logo
    ascii_bold="on"

    # Colors for ASCII logo (yellow, white, black for Tux the penguin)
    ascii_colors=(7 0 3)

    # Regular gap
    gap=3

    # Display settings
    kernel_shorthand="on"
    distro_shorthand="off"
    os_arch="on"
    uptime_shorthand="tiny"
    memory_percent="on"
    memory_unit="gib"
    package_managers="on"
    shell_path="off"
    shell_version="on"
    cpu_brand="on"
    cpu_speed="on"
    cpu_cores="logical"
    cpu_temp="C"
    gpu_brand="on"
    gpu_type="all"
    refresh_rate="on"
    gtk_shorthand="off"
    colors=(distro)
    bold="on"
    underline_enabled="on"
    underline_char="-"
    separator=":"
    color_blocks="on"
    block_range=(0 15)
    block_width=3
    block_height=1
    col_offset="auto"
    bar_char_elapsed="-"
    bar_char_total="="
    bar_border="on"
    bar_length=15
    bar_color_elapsed="distro"
    bar_color_total="distro"
    memory_display="infobar"
    battery_display="infobar"
    disk_display="infobar"
  '';
}
