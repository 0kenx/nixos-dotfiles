{ username, ... }:

{
  # Nix Configuration
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  # Add trusted users
  nix.extraOptions = ''
    trusted-users = root ${username}
  '';
}
