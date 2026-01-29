{pkgs, config, lib, ...}: {
  # Enable GPG agent with 24-hour cache timeout for keys
  services.gpg-agent = {
    enable = true;

    # Cache GPG keys for 24 hours (86400 seconds)
    defaultCacheTtl = 86400;
    maxCacheTtl = 86400;

    # Enable SSH support if using GPG for SSH authentication
    enableSshSupport = false;

    # Use pinentry for password prompts
    pinentry.package = pkgs.pinentry-gnome3;
  };

  # Install GPG
  programs.gpg = {
    enable = true;
  };
}
