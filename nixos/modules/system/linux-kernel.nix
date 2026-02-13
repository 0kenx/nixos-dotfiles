{ pkgs, lib, ... }:

{
  # Linux Kernel - Hardened Configuration with SELinux

  # Security system options
  security = {
    # Memory protection
    forcePageTableIsolation = true;
    virtualisation.flushL1DataCache = "always"; # More secure than "cond"

    # Module loading restrictions
    lockKernelModules = false;

    # Kernel protection
    # protectKernelImage = true;

    # User namespace restrictions
    unprivilegedUsernsClone = false; # More restrictive

    # Linux Security Modules - use mkForce to override default AppArmor LSM setting
    lsm = lib.mkForce [ "landlock" "lockdown" "yama" "integrity" "apparmor" "bpf" "tomoyo" "selinux" ];
  };

  # RAS Daemon - captures MCE (Machine Check Exception) events for hardware error monitoring
  hardware.rasdaemon.enable = true;

  # Use hardened or latest Linux kernel
  # Using 6.18
  boot.kernelPackages = pkgs.linuxPackages_6_18;

  # Kernel command line parameters
  boot.kernelParams = [
    # System logging
    "quiet"
    "splash"
    "loglevel=3"
    "rd.udev.log_priority=3"
    "systemd.show_status=auto"

    # Console settings
    "fbcon=nodefer"
    "vt.global_cursor_default=0"

    # Security settings
    "slab_nomerge"                  # Disable slab merging for better SLAB isolation
    "init_on_alloc=1"               # Zero memory on allocation
    "init_on_free=1"                # Zero memory on free
    "page_alloc.shuffle=1"          # Randomize page allocator
    "pti=on"                        # Force Page Table Isolation
    "randomize_kstack_offset=on"    # Randomize kernel stack offset
    "vsyscall=none"                 # Disable vsyscall
    # "kernel.modules_disabled=1"   # Disabled to allow dm-crypt loading

    # Hardware settings
    "usbcore.autosuspend=-1"
    "video4linux"
    "acpi_rev_override=5"
    "acpi_osi=Linux"                # Improve ACPI compatibility, fixes DPTF symbol errors
    "intel_pstate=passive"          # Allow userspace CPU frequency control (fixes Core Ultra throttling)

    # Intel WiFi BE200 - Firmware stability workaround
    # The BE200 WiFi 7 card has known firmware crashes causing CPU soft lockups
    # Disabling WiFi 7 (802.11be) and power saving improves stability significantly
    "iwlwifi.disable_11be=1"        # Disable WiFi 7, fall back to WiFi 6E
    "iwlwifi.power_save=0"          # Disable power management

    # SELinux settings
    "selinux=1"                     # Enable SELinux
    "enforcing=1"                   # Set SELinux to enforcing mode
  ];

  # Enable required kernel modules
  boot.kernelModules = [
    # Crypto modules - needed for disk encryption
    "dm-crypt"                      # Required for Veracrypt
    # Note: aesni_intel is loaded automatically by the kernel
    "sha256"                        # SHA256 for hashing
    "sha512"                        # SHA512 for hashing
    "xts"                           # XTS mode encryption

    # Intel DPTF thermal modules - fixes DPTF.FCHG symbol errors
    "int3400_thermal"               # Intel DPTF main thermal driver
    "int3403_thermal"               # Intel DPTF sensor driver
    "processor_thermal_device"      # Processor thermal interface
  ];

  # Blacklist problematic or unnecessary modules
  boot.blacklistedKernelModules = [
    # iptable_nat is deprecated in favor of nftables (nf_tables)
    # This prevents the "Failed to find module 'iptable_nat'" warning
  ];

  # Kernel patches and additional configuration
  boot.kernelPatches = [ {
       name = "selinux-hardening";
       patch = null;
       extraConfig = ''
               # SELinux Configuration
               SECURITY_SELINUX y
               SECURITY_SELINUX_BOOTPARAM n
               SECURITY_SELINUX_DEVELOP y
               SECURITY_SELINUX_AVC_STATS y
               DEFAULT_SECURITY_SELINUX y
               DEFAULT_SECURITY_APPARMOR n

               # Module signing (required)
               MODULE_SIG y

               # General hardening options
               SECURITY_LOCKDOWN_LSM y
               SECURITY_LOCKDOWN_LSM_EARLY y
               SECURITY_LANDLOCK y
               SECURITY_YAMA y
               SECURITY_SAFESETID y
               RANDOMIZE_MEMORY y

               # Rust options
               RUST_DEBUG_ASSERTIONS n
               RUST_OVERFLOW_CHECKS y
               RUST_BUILD_ASSERT_ALLOW n
             '';
  } ];

  # Enable SELinux in systemd
  systemd.package = pkgs.systemd.override { withSelinux = true; };

  # SELinux-related packages
  environment.systemPackages = with pkgs; [
    policycoreutils
    selinux-python
    setools
    semodule-utils
    checkpolicy
  ];
}
