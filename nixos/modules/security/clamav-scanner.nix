{ pkgs, ... }:

{
  # Comprehensive ClamAV configuration with weekly scanning
  services.clamav = {
    # Enable weekly scanner instead of real-time scanning
    scanner = {
      enable = true;
      interval = "Sat *-*-* 04:00:00"; # Run every Saturday at 4 AM
    };

    # Disable daemon - we only want weekly scheduled scanning
    daemon.enable = false;

    # Keep updater enabled to get fresh virus definitions
    updater = {
      enable = true;
      interval = "daily";
      frequency = 24; # Update once per day instead of twice
    };

    # Disable Fangfrisch (extra signatures) to reduce resource usage
    fangfrisch.enable = false;
  };

  # Create systemd oneshot service to run scan on demand with restrictions
  systemd.services.clamav-scan-manual = {
    description = "ClamAV on-demand scan";
    path = [ pkgs.clamav ];
    serviceConfig = {
      Type = "oneshot";
      # Use optimized ClamAV scan with exclude patterns
      ExecStart = ''
        ${pkgs.bash}/bin/bash -c '${pkgs.clamav}/bin/clamscan \
        --recursive=yes \
        --quiet \
        --exclude=^/home/[^/]+/Downloads/.*\\.(iso|img|AppImage)$ \
        --exclude=^/home/[^/]+/\\.local/share/Steam/ \
        --exclude=^/home/[^/]+/\\.cache/ \
        --exclude=^/home/[^/]+/\\.npm/ \
        --exclude=^/home/[^/]+/\\.rustup/ \
        --exclude=^/home/[^/]+/\\.cargo/ \
        --max-filesize=100M \
        --max-scansize=500M \
        /home'
      '';
      Nice = 19;
      IOSchedulingClass = "idle";
      CPUSchedulingPolicy = "idle";
    };
    wantedBy = [];
  };
}
