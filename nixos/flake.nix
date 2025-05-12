{
  description = "NixOS Configuration";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
      # Remove wezterm input - we use the one from nixpkgs
      home-manager = {
        url = "github:nix-community/home-manager/release-24.11";
        inputs.nixpkgs.follows = "nixpkgs";
      }; 
      
      # Secret management with sops-nix
      sops-nix = {
        url = "github:Mic92/sops-nix";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      
      # No need to reference nixos-secrets as git repo
      # We assume that /etc/nixos/nixos-secrets exists
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
    
    # Helper function to create NixOS configurations with common modules
    mkNixosConfig = { hostName, hostConfig }: nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        host = hostName;
        pkgs-unstable = pkgsUnstable;
        inherit self inputs username channel pkgs;
      };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix

        # Include host-specific configuration and secrets management
        hostConfig                  # Host-specific config (from hosts/)
        ./modules/per-host.nix      # Host configuration module
        ./modules/secrets.nix       # SOPS secrets configuration
        sops-nix.nixosModules.sops  # Secret management module

        # Modules will be imported by each host configuration
        
        # Home Manager integration
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home;
          
          # Pass flake inputs and system config to home-manager modules
          home-manager.extraSpecialArgs = { 
            inherit inputs username; 
            host = hostName;
          };
        }
      ];
    };
  in
  {
    # Host-specific configurations
    nixosConfigurations = {
      # Default configuration
      dev = mkNixosConfig {
        hostName = "nixos";
        hostConfig = ./hosts/laptop.nix; # Use laptop config for dev
      };
    
      # Laptop configuration
      laptop = mkNixosConfig {
        hostName = "laptop";
        hostConfig = ./hosts/laptop.nix;
      };

      # Workstation configuration
      workstation = mkNixosConfig {
        hostName = "workstation";
        hostConfig = ./hosts/workstation.nix;
      };
    };
  };
}