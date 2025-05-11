# Yubikey Integration with NixOS

This document explains how the Yubikey is integrated into this NixOS configuration for authentication, SSH key management, and SOPS encryption.

## Features

- **SSH Authentication**: Use your Yubikey as an SSH key for secure remote access
- **PAM Authentication**: Enable Yubikey 2FA for login, sudo, and screen unlocking
- **SOPS Integration**: Use your Yubikey for secrets encryption/decryption

## Configuration Components

The Yubikey integration consists of several parts:

1. **Yubikey Basic Setup** (`yubikey.nix`):
   - Configures udev rules for Yubikey detection
   - Sets up PAM modules for authentication
   - Installs required Yubikey software

2. **SSH Integration** (`users.nix`):
   - Configures authorized SSH keys from your Yubikey
   - Sets up the correct permissions and paths

3. **SOPS/Age Integration** (`modules/secrets.nix`):
   - Uses your Yubikey-derived SSH key for age encryption
   - Configures SOPS to use this key for encrypting/decrypting secrets

## Setup Instructions

### 1. Initial Yubikey Configuration

If you haven't already configured your Yubikey for SSH:

```bash
# Install required tools
nix-shell -p yubikey-manager openssh

# Generate a new SSH key on your Yubikey
ssh-keygen -t ed25519-sk -O resident -f ~/.ssh/id_yubikey

# Copy the public key to the repository
cp ~/.ssh/id_yubikey.pub /path/to/nixos-dotfiles/nixos/hosts/common/keys/id_yubidef.pub
```

### 2. PAM U2F Authentication

To set up your Yubikey for login authentication:

1. The system creates an empty `~/.config/Yubico/u2f_keys` file on first boot
2. You need to register your Yubikey with the PAM module:

```bash
# Register your Yubikey (you'll need to touch the key)
pamu2fcfg > ~/.config/Yubico/u2f_keys
```

3. To add multiple Yubikeys, use:

```bash
# Add another Yubikey to the same file
pamu2fcfg -n >> ~/.config/Yubico/u2f_keys
```

### 3. SOPS/Age Integration

The Yubikey is automatically integrated with SOPS for secrets management:

1. Make sure you have the ssh-to-age tool installed:

```bash
# Install the ssh-to-age tool
nix-shell -p ssh-to-age
```

2. Convert your Yubikey's SSH public key to age format:

```bash
# Convert SSH public key to age format
cat nixos/hosts/common/keys/id_yubidef.pub | ssh-to-age
# The output will look like: age1y3ysrwdnhvxtavfsxarr4l7qnweqcc0ttkhkfk3qpcavkzs73fnqlfwfp7
```

3. Add this age public key to your `.sops.yaml` file in the nixos-secrets directory:

```yaml
creation_rules:
  - path_regex: common/.*\.yaml$
    key_groups:
      - age:
        - age1gkw5d3xdnvapspq7tg6z3n47rmz0j6frke9ew77vqrqrmakv7qes3fxws2
        - age1y3ysrwdnhvxtavfsxarr4l7qnweqcc0ttkhkfk3qpcavkzs73fnqlfwfp7
```

And in your `modules/secrets.nix` file, keep only regular SSH keys:

```nix
sops.age = {
  keyFile = "/home/${username}/.config/sops/age/keys.txt";
  # Regular SSH key as fallback (only include real key files here)
  sshKeyPaths = [
    "/home/${username}/.ssh/id_ed25519"  
  ];
};
```

4. Or you can run the setup script which will perform these steps automatically:

```bash
# Run the provided setup script
./nixos-secrets/setup-age-key.sh
```

The script:
- Detects if a Yubikey is present
- Copies or generates the SSH public key
- Uses ssh-to-age to convert the SSH key to age format
- Provides the age public key for your configuration

**Important:** When using a security key like Yubikey with SOPS, there's no actual private key file on disk (it stays in the hardware). That's why we use `publicKeys` instead of `sshKeyPaths` for the Yubikey.

## Usage

### SSH Authentication

Once configured, you can:
- SSH into your system using your Yubikey (touch required)
- Use the key for Git SSH authentication
- Use the key for other SSH-based services

### System Authentication

Your Yubikey provides 2FA for:
- Login screen authentication
- `sudo` command authentication 
- Screen unlocking (with hyprlock)
- Other PAM-enabled services

### SOPS Secret Management

Your Yubikey is used for:
- Encrypting secrets with SOPS
- Decrypting secrets at boot time
- Ensuring only your physical Yubikey can access the secrets

## Troubleshooting

### PKCS11 Provider Error

If you see an error like this:
```
lib_contains_symbol: open /usr/lib/opensc-pkcs11.so: No such file or directory
provider /usr/lib/opensc-pkcs11.so is not a PKCS11 library
```

This occurs because the SSH configuration is looking for the OpenSC library in the wrong location. To fix it:

1. Make sure opensc is installed in your NixOS configuration:
   ```nix
   environment.systemPackages = with pkgs; [
     # other packages...
     opensc
     pcsc-tools
   ];
   ```

2. Find the correct path to the opensc-pkcs11.so library:
   ```bash
   find /nix/store -name "opensc-pkcs11.so" | head -n 1
   ```

3. Update your SSH config with the correct path:
   ```bash
   sed -i "s|PKCS11Provider .*|PKCS11Provider $(find /nix/store -name "opensc-pkcs11.so" | head -n 1)|" ~/.ssh/config
   ```

4. Test that SSH can now find the library:
   ```bash
   ssh-add -L
   # Should show your Yubikey-based key
   ```

### SSH Key Issues

If SSH is not detecting your Yubikey:

1. Make sure the PKCS11 provider is properly configured:
   ```bash
   # Check SSH config
   cat ~/.ssh/config
   # Should contain a line with PKCS11Provider pointing to a valid opensc-pkcs11.so file
   
   # Find opensc-pkcs11.so
   find /nix/store -name "opensc-pkcs11.so" | head -n 1
   
   # Update your SSH config with the correct path
   sed -i "s|PKCS11Provider .*|PKCS11Provider $(find /nix/store -name "opensc-pkcs11.so" | head -n 1)|" ~/.ssh/config
   ```

2. Test SSH agent recognition:
   ```bash
   ssh-add -L
   # Should list your Yubikey-based key
   ```

### PAM Authentication Issues

If PAM authentication is not working:

1. Check your u2f_keys file:
   ```bash
   cat ~/.config/Yubico/u2f_keys
   # Should contain your key registration
   ```

2. Try re-registering your key:
   ```bash
   pamu2fcfg > ~/.config/Yubico/u2f_keys
   ```

3. Check PAM module loading:
   ```bash
   grep pam_u2f /etc/pam.d/sudo
   # Should show the module is configured
   ```

### SOPS Decryption Issues

If you see an error like this during `nixos-rebuild`:

```
Cannot read ssh key '/home/dev/.ssh/id_yubikey': open /home/dev/.ssh/id_yubikey: no such file or directory
```

This occurs because the configuration is trying to use a non-existent private key file. Security keys like Yubikeys don't have private key files on disk. To fix this:

1. Remove the Yubikey path from `sshKeyPaths` in `modules/secrets.nix`:
   ```nix
   sops.age = {
     # Keep only real files here
     sshKeyPaths = [
       "/home/${username}/.ssh/id_ed25519"
       # Remove the line with /home/${username}/.ssh/id_yubikey
     ];
     # Add the Yubikey's public key in age format here instead
     publicKeys = [
       "age1y3ysrwdnhvxtavfsxarr4l7qnweqcc0ttkhkfk3qpcavkzs73fnqlfwfp7"
     ];
   };
   ```

2. Make sure your Yubikey is plugged in during boot

3. If needed, verify the age key generation:
   ```bash
   cat ~/.config/sops/age/yubikey.txt
   ```

## Security Considerations

1. **Physical Security**: Your Yubikey must be physically present for authentication
2. **Touch Requirement**: Most operations require a physical touch, preventing remote exploitation
3. **Key Backup**: Consider having a backup Yubikey configured for emergencies
4. **Recovery Plan**: Have a recovery method if your Yubikey is lost or damaged

## Additional Resources

- [Yubikey SSH Documentation](https://developers.yubico.com/SSH/)
- [Yubikey with PAM](https://developers.yubico.com/pam-u2f/)
- [SOPS-Nix Documentation](https://github.com/Mic92/sops-nix)