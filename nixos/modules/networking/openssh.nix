{ pkgs, lib, ... }:

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

  # Configure SSH client for PKCS11
  programs.ssh = {
    # Set up OpenSC PKCS11 provider for SSH
    extraConfig = ''
      # Commented out to prevent PKCS prompt during git push
      # PKCS11Provider ${pkgs.opensc}/lib/opensc-pkcs11.so
    '';
  };

  # Enable GPG
  services.pcscd.enable = true;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-tty;
  };
}
