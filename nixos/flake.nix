{
  description = "NixOS Configuration";

  inputs = {
      nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
      nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
      rust-overlay.url = "github:oxalica/rust-overlay";
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

    # Function to generate a NixOS system for a specific host
    mkNixosSystem = { hostname }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          host = hostname;
          pkgs-unstable = pkgsUnstable;
          inherit self inputs username channel pkgs;
        };
        modules = [
          # Important: The import order has been carefully designed to avoid infinite recursion

          # 1. First load hardware configuration (needed by other modules)
          ./hardware-configuration.nix

          # 2. Then include host-specific configuration (actual values for host configuration)
          ./hosts/${hostname}/default.nix

          # 3. Core configuration (automatically imports host-config schema + core modules + module-manager)
          # The module-manager will then conditionally import other modules based on host configuration
          ./configuration.nix

          # 4. Secret management with sops-nix (after core system is configured)
          sops-nix.nixosModules.sops

          # 5. Home Manager integration last
            # inputs.home-manager.nixosModules.home-manager
            # {
            # home-manager.useGlobalPkgs = true;
            # home-manager.useUserPackages = true;
            # home-manager.backupFileExtension = "backup";

            # Pass all necessary parameters explicitly to home/default.nix
            # home-manager.users.${username} = import ./home {
            #   inherit inputs username channel;
            #   host = hostname;
            # };

            # Pass flake inputs and system config to home-manager modules
            # home-manager.extraSpecialArgs = {
            #   inherit inputs username channel;
            #   host = hostname;
            # };
            # }
        ];
      };
  in
  {
    # Host-specific configurations
    nixosConfigurations = {
      # Main development machine configuration (generic default for development)
      dev = mkNixosSystem { hostname = "workstation"; };

      # Specific host configurations
      laptop = mkNixosSystem { hostname = "laptop"; };
      workstation = mkNixosSystem { hostname = "workstation"; };
    };
  };
}
