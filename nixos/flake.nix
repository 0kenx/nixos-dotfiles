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
    };
    pkgsUnstable = import nixpkgs-unstable {
      inherit system;
      config = commonNixpkgsConfig; # Apply the common config here too
    };
    lib = pkgs.lib;
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

          # Include host-specific configuration
          ./hosts/example-workstation.nix  # Example host configuration

          # Secret management with sops-nix
          sops-nix.nixosModules.sops  # Secret management module

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
  };
}
