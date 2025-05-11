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

1. Run the setup script to configure your Yubikey with age:

```bash
# Install the ssh-to-age tool first
nix-shell -p ssh-to-age

# Run the provided setup script
./nixos-secrets/setup-age-key.sh
```

2. This script:
   - Detects if a Yubikey is present
   - Copies or generates the SSH public key
   - Uses ssh-to-age to convert the SSH key to age format
   - Updates the SOPS configuration with the correct key

3. The `sops.age.sshKeyPaths` setting in `secrets.nix` ensures SOPS uses your Yubikey-derived key. SOPS automatically converts the SSH key to age format during encryption/decryption.

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

If SOPS fails to decrypt with your Yubikey:

1. Make sure your Yubikey is plugged in during boot
2. Check if the SSH key is available:
   ```bash
   ls -la ~/.ssh/id_yubikey*
   ```
3. Verify the age key generation:
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