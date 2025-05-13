# Hyprland display configuration based on host settings
{ config, lib, pkgs, nixosConfig, ... }:

let
  # Safely access host configuration with defaults to prevent errors
  getNixOSConfigPath = path: default:
    let
      splitPath = lib.splitString "." path;
      result = lib.getAttrFromPath splitPath nixosConfig;
    in
      if result == null then default else result;

  # Try to safely get config values or fall back to defaults
  primary = getNixOSConfigPath "system.nixos-dotfiles.host.displays.primary" "eDP-1";
  secondary = getNixOSConfigPath "system.nixos-dotfiles.host.displays.secondary" null;
  tertiary = getNixOSConfigPath "system.nixos-dotfiles.host.displays.tertiary" null;

  # Scale factors with defaults
  primaryScale = toString (getNixOSConfigPath "system.nixos-dotfiles.host.displays.primaryScale" 1.0);
  secondaryScale = toString (getNixOSConfigPath "system.nixos-dotfiles.host.displays.secondaryScale" 1.0);
  tertiaryScale = toString (getNixOSConfigPath "system.nixos-dotfiles.host.displays.tertiaryScale" 1.0);

  # Rotation settings
  getRotate = rotation:
    if rotation == "left" then "1" else
    if rotation == "right" then "3" else
    if rotation == "inverted" then "2" else
    "0"; # normal rotation

  secondaryRotate = getNixOSConfigPath "system.nixos-dotfiles.host.displays.secondaryRotate" null;
  tertiaryRotate = getNixOSConfigPath "system.nixos-dotfiles.host.displays.tertiaryRotate" null;

  secondaryTransform = if secondaryRotate != null
    then ",transform,${getRotate secondaryRotate}"
    else "";

  tertiaryTransform = if tertiaryRotate != null
    then ",transform,${getRotate tertiaryRotate}"
    else "";

  # Position settings (use explicit positions if provided, otherwise use auto positions)
  secondaryPos = getNixOSConfigPath "system.nixos-dotfiles.host.displays.secondaryPosition" "auto-right";
  tertiaryPos = getNixOSConfigPath "system.nixos-dotfiles.host.displays.tertiaryPosition" "auto-right";

  # Build the monitor configuration lines
  primaryMonitor = "${primary},preferred,auto,${primaryScale}";
  secondaryMonitor = if secondary != null
    then "${secondary},preferred,${secondaryPos},${secondaryScale}${secondaryTransform}"
    else "";
  tertiaryMonitor = if tertiary != null
    then "${tertiary},preferred,${tertiaryPos},${tertiaryScale}${tertiaryTransform}"
    else "";

  # Generate monitor list for Hyprland
  monitorList = lib.filter (m: m != "") [
    primaryMonitor
    secondaryMonitor
    tertiaryMonitor
  ];

  # Generate workspace assignments for monitors
  workspaceAssignments =
    # Primary monitor workspaces (1-10)
    (map (i: "${toString i},monitor:${primary}") (lib.range 1 10)) ++

    # Secondary monitor workspaces (11-20)
    (if secondary != null then
      (map (i: "${toString i},monitor:${secondary}") (lib.range 11 20))
    else []) ++

    # Tertiary monitor workspaces (21-30)
    (if tertiary != null then
      (map (i: "${toString i},monitor:${tertiary}") (lib.range 21 30))
    else []);
in {
  # Export for use in hyprland.nix
  hyprlandConfig = {
    monitors = monitorList;
    workspaces = workspaceAssignments;

    # Script to initialize display layout dynamically
    monitorPositioningScript = ''
      # Apply monitor positions dynamically

      # Function to get display geometry
      get_geometry() {
        hyprctl monitors -j | jq -r ".[] | select(.name==\"$1\") | $2"
      }

      # Configure monitors if more than one is connected
      if [ "$(hyprctl monitors -j | jq '. | length')" -gt "1" ]; then
        # Set up primary display
        hyprctl keyword monitor "${primaryMonitor}"

        # Set up secondary display if present
        ${if secondary != null then ''
          # Check if explicit positioning is provided
          ${if secondaryPos != "auto-right" then ''
            # Use explicit position from host config
            hyprctl keyword monitor "${secondary},preferred,${secondaryPos},${secondaryScale}${secondaryTransform}"
          '' else ''
            # Get primary display dimensions for auto-positioning
            primary_height=$(get_geometry "${primary}" ".height")
            primary_width=$(get_geometry "${primary}" ".width")

            # Get secondary display dimensions
            secondary_height=$(get_geometry "${secondary}" ".height")
            secondary_width=$(get_geometry "${secondary}" ".width")

            # Adjust position based on rotation
            ${if secondaryRotate == "left" || secondaryRotate == "right" then ''
              # For vertical orientation, align bottom edge with primary display
              # For left rotation, the width becomes height
              y_pos=$(( $primary_height - $secondary_width ))
              position="$primary_width\x-$y_pos"
            '' else ''
              # For horizontal orientation, place on the right of primary
              position="$primary_width\x0"
            ''}

            # Apply secondary display configuration
            hyprctl keyword monitor "${secondary},preferred,$position,${secondaryScale}${secondaryTransform}"
          ''}
        '' else ""}

        # Set up tertiary display if present
        ${if tertiary != null then ''
          # Check if explicit positioning is provided
          ${if tertiaryPos != "auto-right" then ''
            # Use explicit position from host config
            hyprctl keyword monitor "${tertiary},preferred,${tertiaryPos},${tertiaryScale}${tertiaryTransform}"
          '' else ''
            # Determine position based on other monitors
            ${if secondary != null then ''
              # If we have both secondary and tertiary, calculate position
              # Get secondary display position and dimensions
              secondary_x=$(get_geometry "${secondary}" ".x")
              secondary_y=$(get_geometry "${secondary}" ".y")
              secondary_total_width=$(get_geometry "${secondary}" ".width")
              secondary_total_height=$(get_geometry "${secondary}" ".height")

              # Calculate position for tertiary
              tertiary_x=$secondary_x
              tertiary_y=$(( $secondary_y + $secondary_total_height ))
              position="$tertiary_x\x$tertiary_y"
            '' else ''
              # If we only have primary and tertiary, place tertiary to the right
              primary_width=$(get_geometry "${primary}" ".width")
              position="$primary_width\x0"
            ''}

            # Apply tertiary display configuration
            hyprctl keyword monitor "${tertiary},preferred,$position,${tertiaryScale}${tertiaryTransform}"
          ''}
        '' else ""}
      else
        # Only one monitor, just configure primary
        hyprctl keyword monitor "${primaryMonitor}"
      fi
    '';
  };
}
