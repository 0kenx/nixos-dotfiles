{ config, lib, pkgs, ... }:

{
  # Automatic cleanup of home-manager backup files before activation
  system.activationScripts.cleanHomeManagerBackups = {
    text = ''
      echo "Cleaning up home-manager backup files..."
      
      # Get all users with home directories
      for user_home in /home/*; do
        if [ -d "$user_home/.config" ]; then
          username=$(basename "$user_home")
          
          # Find all .backup files in .config directory
          find "$user_home/.config" -name "*.backup" -type f | while read -r backup_file; do
            # Skip if filepath contains 'storage' or 'data' (case insensitive)
            if echo "$backup_file" | grep -qi -E '(storage|data)'; then
              continue
            fi
            
            # Get the original filename by removing .backup suffix
            original_file="''${backup_file%.backup}"
            
            # If the original file exists and is NOT a symlink, remove the backup
            if [ -f "$original_file" ] && [ ! -L "$original_file" ]; then
              echo "Removing $backup_file (original exists and is not a symlink: $original_file)"
              rm -f "$backup_file"
            fi
          done
        fi
      done
    '';
    
    # Run before home-manager activation
    deps = [];
  };
}