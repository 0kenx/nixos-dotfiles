{ pkgs, lib, ... }:

{
  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Enable Security Services
  users.users.root.hashedPassword = "!";

  # GNOME Keyring for password storage (works with Hyprland)
  services.gnome.gnome-keyring.enable = true;
  programs.seahorse.enable = true;  # GUI for managing keys

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };
  security.apparmor = {
    enable = true;
    packages = with pkgs; [
      apparmor-utils
      apparmor-profiles
    ];
  };
  services.fail2ban.enable = true;
  security.pam.services.hyprlock = {};
  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id.indexOf("org.bluez") == 0 &&
          (subject.isInGroup("users") || subject.isInGroup("bluetooth"))) {
        return polkit.Result.YES;
      }
    });
  '';

  # Improve HID device permissions
  services.udev.extraRules = ''
    # Logitech devices
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="046d", MODE="0666"

    # Generic HID device rules
    ACTION=="add", SUBSYSTEM=="bluetooth", ATTR{type}=="1", RUN+="${pkgs.bluez}/bin/bluetoothctl -- connect %s{uniq}"
  '';
  programs.browserpass.enable = true;
  # ClamAV moved to dedicated clamav-scanner.nix module
  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      mpv = {
        executable = "${lib.getBin pkgs.mpv}/bin/mpv";
        profile = "${pkgs.firejail}/etc/firejail/mpv.profile";
      };
      imv = {
        executable = "${lib.getBin pkgs.imv}/bin/imv";
        profile = "${pkgs.firejail}/etc/firejail/imv.profile";
      };
      zathura = {
        executable = "${lib.getBin pkgs.zathura}/bin/zathura";
        profile = "${pkgs.firejail}/etc/firejail/zathura.profile";
      };
      discord = {
        executable = "${lib.getBin pkgs.discord}/bin/discord";
        profile = "${pkgs.firejail}/etc/firejail/discord.profile";
      };
      slack = {
        executable = "${lib.getBin pkgs.slack}/bin/slack";
        profile = "${pkgs.firejail}/etc/firejail/slack.profile";
      };
      telegram-desktop = {
        executable = "${lib.getBin pkgs.tdesktop}/bin/telegram-desktop";
        profile = "${pkgs.firejail}/etc/firejail/telegram-desktop.profile";
      };
      brave = {
        executable = "${lib.getBin pkgs.brave}/bin/brave";
        profile = "${pkgs.firejail}/etc/firejail/brave.profile";
      };
      qutebrowser = {
        executable = "${lib.getBin pkgs.qutebrowser}/bin/qutebrowser";
        profile = "${pkgs.firejail}/etc/firejail/qutebrowser.profile";
      };
      thunar = {
        executable = "${lib.getBin pkgs.xfce.thunar}/bin/thunar";
        profile = "${pkgs.firejail}/etc/firejail/thunar.profile";
      };
      vscodium = {
        executable = "${lib.getBin pkgs.vscodium}/bin/vscodium";
        profile = "${pkgs.firejail}/etc/firejail/vscodium.profile";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    vulnix       #scan command: vulnix --system
    clamav       #scan command: sudo freshclam; clamscan [options] [file/directory/-]
    chkrootkit   #scan command: sudo chkrootkit

    # Disk encryption
    veracrypt    # GUI/CLI tool for creating and mounting encrypted volumes

    # Password and security tools
    pass-wayland
    pass2csv
    passExtensions.pass-tomb
    passExtensions.pass-update
    passExtensions.pass-otp
    passExtensions.pass-import
    passExtensions.pass-audit
    tomb
    pwgen
    pwgen-secure

    # Network scanning and enumeration
    nmap
    masscan
    arp-scan

    # Vulnerability scanning
    nikto
    nuclei
    sqlmap

    # Web application testing
    burpsuite
    gobuster
    ffuf
    wfuzz

    # Wireless tools
    aircrack-ng

    # Network analysis and sniffing
    wireshark
    tcpdump
    ettercap

    # Password cracking
    john
    hashcat
    hashcat-utils
    hydra

    # Exploitation and enumeration
    metasploit
    exploitdb

    # Forensics
    sleuthkit
    binwalk

    # Reverse engineering
    radare2
    ghidra

    # Network utilities
    netcat-gnu
    socat

    # OSINT tools
    theharvester
    sherlock
    recon-ng
    maltego
    photon
    amass
    whatweb
    wafw00f
    dnsenum
    dnsrecon
    fierce
    exiftool
    socialscan
  ];
}
