{
  description = "NixOS Configuration";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
      # wezterm.url = "github:wez/wezterm?dir=nix";
      home-manager = {
        url = "github:nix-community/home-manager/release-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
      }; 
      
      # Secret management with sops-nix
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      
      # Private secrets repository (submodule)
      # This references the Git submodule at ../nixos-secrets
      # To use this, run:
      # git submodule add git@github.com:0kenx/nixos-secrets.git nixos-secrets
      secrets = {
        url = "git+file:../nixos-secrets";
        flake = false;
      };
  };

  outputs = { nixpkgs, nixpkgs-unstable, self, sops-nix, ... } @ inputs:
  let
    username = "dev";
    system = "x86_64-linux";
    channel = "24.11";
    # Define a common nixpkgs configuration
    commonNixpkgsConfig = {
      allowUnfree = true;
      #cudaSupport = true;
      # You can add other shared configurations like overlays here if needed
    };
    pkgs = import nixpkgs {
      inherit system;
      config = commonNixpkgsConfig; # Apply the common config
      #overlays = [
      #  framepackOverlay
      #];
    };
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config = commonNixpkgsConfig; # Apply the common config here too
    };
    lib = pkgs.lib;
    # Define the overlay for FramePack
    #framepackOverlay = final: prev: {
      # Add framepack to the package set
    #  framepack = final.python310Packages.callPackage ./pkgs/framepack.nix {
        # Pass pkgs for system-level dependencies like ffmpeg, opencv4 itself
    #    pkgs = final;
        # torchWithCuda is expected to be resolved from final.python310Packages
        # If framepack.nix was defined to take python310Packages.torchWithCuda explicitly:
        # torchWithCuda = final.python310Packages.torchWithCuda;
    #  };
    #};
  in
  {
    # Host-specific configurations
    nixosConfigurations = {
      # Main development machine configuration
      dev = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { 
          host = "nixos";
          pkgs-unstable = pkgsUnstable;
          inherit self inputs username channel pkgs; 
        };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        
        # Include host-specific configuration and secrets management
        ./hosts/example-laptop.nix  # This is a placeholder, replace with actual host config
        ./modules/per-host.nix      # Host configuration module
        ./modules/secrets.nix       # SOPS secrets configuration
        sops-nix.nixosModules.sops  # Secret management module
        
        # System modules
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
	./cad.nix
        ./multimedia.nix
        
        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home;
          
          # Pass flake inputs and system config to home-manager modules
          home-manager.extraSpecialArgs = { 
            inherit inputs username; 
            host = "nixos";
          };
        }
      ];
    };
  };
}
