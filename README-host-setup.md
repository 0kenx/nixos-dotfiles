# Host-Specific Configuration Guide

This NixOS configuration setup now supports host-specific configurations, allowing you to:

1. Maintain different Git identities on different machines
2. Keep secret or sensitive information separate from shared configuration
3. Configure hardware-specific settings like monitor layouts

## How It Works

The configuration is now structured with:

1. **Shared Modules**: Common configurations used across all machines
2. **Host-Specific Modules**: Configuration that varies between machines
3. **Per-Host Configuration**: Options defined in `hosts/your-hostname.nix`

## Setting Up a New Machine

To set up a new machine:

1. Create a new host configuration file in the `hosts/` directory:

```bash
cp hosts/example-laptop.nix hosts/your-hostname.nix
```

2. Edit `hosts/your-hostname.nix` to configure machine-specific settings:

```nix
{config, lib, pkgs, ...}: {
  imports = [
    ../modules/per-host.nix
  ];
  
  # Configuration specific to this host
  nixosConfig.system.nixos-dotfiles = {
    git = {
      user = {
        name = "Your Name";  # Git username for this machine
        email = "your.email@example.com";  # Git email for this machine
        signingKey = "YOUR_GPG_KEY_ID";  # GPG key for this machine
      };
      includes = [
        {
          condition = "gitdir:~/projects/";
          contents = {
            user = {
              name = "Personal Name"; 
              email = "personal@example.com";
            };
          };
        }
        # Add more directory-specific configurations
      ];
    };
    
    hyprland = {
      monitors = [
        "YOUR-MONITOR-1,preferred,auto,1.0"
        "YOUR-MONITOR-2,preferred,auto,1.0"
      ];
    };
  };
}
```

3. Modify the `flake.nix` to include your new host configuration:

```nix
# In flake.nix
nixosConfigurations = {
  your-hostname = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { 
      host = "your-hostname";
      pkgs-unstable = pkgsUnstable;
      inherit self inputs username channel pkgs; 
    };
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      
      # Include host-specific configuration
      ./hosts/your-hostname.nix  # Your host-specific config
      ./modules/per-host.nix     # Host configuration module
      
      # ... other modules ...
      
      # Home Manager integration
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.${username} = import ./home;
        
        # Pass flake inputs and system config to home-manager modules
        home-manager.extraSpecialArgs = { 
          inherit inputs username; 
          host = "your-hostname";
        };
      }
    ];
  };
  
  # ... other host configurations ...
};
```

4. Build and switch to your configuration:

```bash
sudo nixos-rebuild switch --flake .#your-hostname
```

## Available Host-Specific Options

Currently, the following host-specific options are available:

### Git Configuration

- `nixosConfig.system.nixos-dotfiles.git.user.name`: Default Git username
- `nixosConfig.system.nixos-dotfiles.git.user.email`: Default Git email
- `nixosConfig.system.nixos-dotfiles.git.user.signingKey`: GPG key for signing commits
- `nixosConfig.system.nixos-dotfiles.git.includes`: Directory-specific Git configurations

### Hyprland Configuration

- `nixosConfig.system.nixos-dotfiles.hyprland.monitors`: Monitor configurations for Hyprland

## Adding New Host-Specific Options

To add new host-specific options:

1. Edit `modules/per-host.nix` to add your new option
2. Update the relevant configuration file(s) to use the new option
3. Add the option to your host-specific file(s)

## Best Practices

1. Keep sensitive information (API keys, private tokens) in host-specific files
2. Use conditional includes for Git to manage multiple identities
3. Maintain a separate configuration for each physical machine
4. Keep hardware-specific settings in the host configuration