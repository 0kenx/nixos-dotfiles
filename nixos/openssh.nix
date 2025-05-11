{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    openssl
    gnupg
    pinentry-tty
    veracrypt
    opensc
    pcsc-tools
  ];

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "dev" ];
    };
  };

  # Enable GPG
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
}
