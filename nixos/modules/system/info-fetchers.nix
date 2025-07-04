{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # neofetch (moved to home-manager)
    onefetch
    ipfetch
    cpufetch
    ramfetch
    starfetch
    octofetch
    htop
    bottom
    zfxtop
    kmon
    btop
    hdparm
    lsof
    duf
    powertop
    tlp
    powercap
    # benchmark/stress
    stress-ng
    sysbench

    # vulkan-tools
    # opencl-info
    # clinfo
    # vdpauinfo
    # libva-utils
    # nvtopPackages.nvidia
    # nvtopPackages.intel
    wlr-randr
    gpu-viewer
    dig
    speedtest-rs
  ];
}