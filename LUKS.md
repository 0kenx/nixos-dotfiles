* Setting up NixOs with LUKS encrypted root

Here are my working notes on getting a system up and running. It creates an unencrypted boot partition and a LUKS system partition with encrypted swap.

WARNING: You can run into a hidden problem that will prevent a correct partition setup and =/etc/nixos/configuration.nix= from working: if you are setting up a UEFI system, then you need to make sure you boot into the NixOS installation from the UEFI partition of the bootable media. You may have to enter your BIOS boot selection menu to verify this. For example, if you setup a NixOS installer image on a flash drive, your BIOS menu may display several boot options from that flash drive: choose the one explicitly labeled with "UEFI".

** References

I used these resources:

- Nixos manual https://nixos.org/nixos/manual/index.html#sec-installation
- Nixos wiki on full disk encryption https://nixos.wiki/wiki/Full_Disk_Encryption
- martijnvermaat's gist from 2016 https://gist.github.com/martijnvermaat/76f2e24d0239470dd71050358b4d5134
- luks FAQ https://gitlab.com/cryptsetup/cryptsetup/-/wikis/FrequentlyAskedQuestions#2-setup
-

** Prep Disk

Start by taking a look at block devices and identify the name of the device you're setting up. Note that adding the =--fs= flag will show the UUID of each device.

#+begin_src sh
lsblk
#+end_src

Wipe existing fs. on my machine the primary disk is /dev/sda, but it may be different on different machines. Note that Cryptsetup FAQ suggests we use =cat /dev/zero > [device target]=

#+begin_src sh
sudo wipefs -a /dev/sda
#+end_src

** Partition

Create a new partition table

#+begin_src sh
sudo parted /dev/sda -- mklabel gpt
#+end_src

Create the boot partition at the beginning of the disk

#+begin_src sh
sudo parted /dev/sda -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/sda -- set 1 boot on
#+end_src

Create primary partition

#+begin_src sh
sudo parted /dev/sda -- mkpart primary 512MiB 100%
#+end_src

Now =/dev/sda1= is our boot partition, and =/dev/sda2= is our primary.

** Encrypt Primary Disk

Setup luks on sda2 (=crypted= is the label). This will prompt for creating a password.

#+begin_src sh
sudo cryptsetup luksFormat /dev/sda2
sudo cryptsetup luksOpen /dev/sda2 crypted
#+end_src

Map the physical, encrypted volume, then create a new volume group and logical volumes in that group for our nixos root and our swap.

#+begin_src sh
sudo pvcreate /dev/mapper/crypted
sudo vgcreate vg /dev/mapper/crypted
sudo lvcreate -L 8G -n swap vg
sudo lvcreate -l '100%FREE' -n nixos vg
#+end_src

** Format Disks

The boot volume will be fat32. The filesystem will be ext4. Also creating a swap.

#+begin_src sh
sudo mkfs.fat -F 32 -n boot /dev/sda1
sudo mkfs.ext4 -L nixos /dev/vg/nixos
sudo mkswap -L swap /dev/vg/swap
#+end_src


** Mount

Mount the target file system to /mnt

#+begin_src sh
sudo mount /dev/disk/by-label/nixos /mnt
#+end_src

Mount the boot file system on /mnt/boot for UEFI boot

#+begin_src sh
sudo mkdir -p /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot
#+end_src

Activate swap

#+begin_src sh
sudo swapon /dev/vg/swap
#+end_src

** Resulting Disk

Expect the following result:

#+begin_src txt
NAME           MAJ:MIN RM   SIZE RO TYPE  MOUNTPOINT
loop0            7:0    0   1.1G  1 loop  /nix/.ro-store
sda              8:0    0 232.9G  0 disk
├─sda1           8:1    0   511M  0 part  /mnt/boot
└─sda2           8:2    0 232.4G  0 part
  └─crypted    254:0    0 232.4G  0 crypt
    ├─vg-swap  254:1    0     8G  0 lvm   [SWAP]
    └─vg-nixos 254:2    0 224.4G  0 lvm   /mnt
#+end_src


** Configure boot

generate configuration

#+begin_src sh
sudo nixos-generate-config --root /mnt
#+end_src


Edit configuration. Here is the part pertinent to luks setup:

#+begin_src nix
{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nixpkgs.config.allowUnfree = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # grub
  boot.loader.grub = {
    enable = true;
    version = 2;
    efiSupport = true;
    enableCryptodisk = true;
    device = "nodev";
  };

  # luks
  boot.initrd.luks.devices = {
    crypted = {
      device = "/dev/disk/by-uuid/<the uuid of /dev/sda2 in this example>";
      preLVM = true;
    };
  };

  boot.kernelParams = [ "processor.max_cstate=4" "amd_iomu=soft" "idle=nomwait"];
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];

  ##
  # ...
  ##

  system.stateVersion = "20.03";
}
#+end_src

Note the line =boot.loader.grub.device = "nodev";= this is a special value: https://nixos.org/nixos/manual/options.html#opt-boot.loader.grub.device

"The device on which the GRUB boot loader will be installed. The special value nodev means that a GRUB boot menu will be generated, but GRUB itself will not actually be installed."

Note the absence of =boot.loader.efi.efiSysMountPoint = "/boot/efi"=; my installation would not succeed if I specified this.

Note that the name of the encrypted filesystem in =boot.initrd.luks.devices= is the name used in =cryptsetup luksOpen= and in =vgcreate=.


** Install NixOs

Run the install

#+begin_src sh
sudo nixos-install
#+end_src

If install is successful, you'll be prompted to set password for root user. Then =reboot=, and remove installation media.

Login to root, and add add user:

#+begin_src sh
useradd -c 'Me' -m me
passwd me
#+end_src

** Perf test
```
# compare
nix-shell -p hdparm --run "hdparm -Tt /dev/mapper/cryptroot"
# with
nix-shell -p hdparm --run "hdparm -Tt /dev/sda1"
```
I had to add a few modules to initrd to make it fast. Since cryptroot is opened really early on, all the AES descryption modules should already be made available. This obviously depends on the platform that you are on.
```
{
   boot.initrd.availableKernelModules = [
    "aesni_intel"
    "cryptd"
  ];
}
```
