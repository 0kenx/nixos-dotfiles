{
  description = "NixOS Configuration";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
      wezterm.url = "github:wez/wezterm?dir=nix";
      home-manager = {
        url = "github:nix-community/home-manager/release-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
      }; 
  };

  outputs = { nixpkgs, nixpkgs-unstable, self, ... } @ inputs:
  let
    username = "dev";
    system = "x86_64-linux";
    channel = "24.11";
    # Define a common nixpkgs configuration
    commonNixpkgsConfig = {
      allowUnfree = true;
      # You can add other shared configurations like overlays here if needed
    };
    pkgs = import nixpkgs {
      inherit system;
      config = commonNixpkgsConfig; # Apply the common config
    };
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config = commonNixpkgsConfig; # Apply the common config here too
    };
    lib = pkgs.lib;
  in
  {
    nixosConfigurations.dev = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { 
        host = "nixos";
        pkgs-unstable = pkgsUnstable;
        inherit self inputs username channel pkgs; 
      };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        # ./core-pkgs.nix
        ./nvidia.nix
        # ./disable-nvidia.nix
        ./opengl.nix
        # ./fingerprint-scanner.nix
        # ./clamav-scanner.nix
        ./yubikey.nix
        ./sound.nix
        ./usb.nix
        ./keyboard.nix
        ./time.nix
        ./swap.nix
        ./bootloader.nix
        ./nix-settings.nix
        ./nixpkgs.nix
        ./gc.nix
        # ./auto-upgrade.nix
        ./linux-kernel.nix
        ./screen.nix
        # ./location.nix
        ./display-manager.nix
        ./theme.nix
        ./internationalisation.nix
        ./fonts.nix
        ./security-services.nix
        ./services.nix
        # ./printing.nix
        # ./gnome.nix
        ./hyprland.nix
        ./environment-variables.nix
        ./bluetooth.nix
        ./networking.nix
        # ./mac-randomize.nix
        ./openssh.nix
	./firewall.nix
        ./dns.nix
        ./vpn.nix
        ./users.nix
        ./virtualisation.nix
        ./programming-languages.nix
        ./lsp.nix
        ./wasm.nix
        ./info-fetchers.nix
        ./utils.nix
        ./terminal-utils.nix
        ./llm.nix
        ./work.nix
      ];
    };
  };
}
