# Secret Management with sops-nix

This NixOS configuration uses [sops-nix](https://github.com/Mic92/sops-nix), a tool that integrates Mozilla's SOPS (Secrets OPerationS) with the Nix ecosystem. This document explains how the secrets management system works.

## Directory Structure

The secrets are stored in the `nixos/nixos-secrets` directory with this structure:
```
nixos-secrets/
├── common/             # Shared secrets across all hosts
│   └── secrets.yaml    # Contains API keys and other global secrets
├── hosts/              # Host-specific secrets
│   ├── desktop/        
│   │   └── secrets.yaml # Desktop-specific Git credentials
│   └── laptop/         
│       └── secrets.yaml # Laptop-specific Git credentials
├── .sops.yaml          # SOPS configuration file 
├── encrypt-secrets.sh  # Script to encrypt secrets
└── setup-age-key.sh    # Script to set up age encryption keys
```

## Encryption Setup

- The system uses `age` for encryption, which is a simple, modern file encryption tool
- Your age key is stored at `~/.config/sops/age/keys.txt`
- The public key is configured in `.sops.yaml`, which tells SOPS which files to encrypt and with which keys

## Secret Definition and Access

In `modules/secrets.nix`:

1. **Secret Declaration**: All secrets are declared with paths and ownership
   ```nix
   sops.secrets = {
     "git/default_name" = {
       owner = "dev";
     };
     # API keys with specific file path
     "api_keys/github" = {
       owner = "dev";
       sopsFile = ../nixos-secrets/common/secrets.yaml;
     };
     # ... other secrets
   };
   ```

2. **Default File Location**: By default, host-specific secrets are loaded from the host's file
   ```nix
   defaultSopsFile = ../nixos-secrets/hosts/desktop/secrets.yaml;
   ```

3. **Environment Variables**: Secrets are exposed as environment variables
   ```nix
   environment.sessionVariables = {
     GIT_DEFAULT_NAME = config.sops.secrets."git/default_name".path;
     # ... other variables
   };
   ```

## Secret Usage

In your configuration files like `home/git.nix`, secrets are accessed via shell commands that read from the mounted secret files:

```nix
# Git configuration using secrets
userName = "$(cat $GIT_DEFAULT_NAME 2>/dev/null || echo 'Default User')";
userEmail = "$(cat $GIT_DEFAULT_EMAIL 2>/dev/null || echo 'default@example.com')";
```

## How it Works at Runtime

1. When NixOS boots, the sops-nix service:
   - Decrypts the secrets using your age key
   - Mounts each secret at a path under `/run/secrets/`
   - Sets permissions according to the configured owners

2. Environment variables like `GIT_DEFAULT_NAME` point to these paths:
   - Example: `GIT_DEFAULT_NAME=/run/secrets/git/default_name`

3. Applications can read these secrets directly from the mounted files
   - In your Git config, shell commands like `$(cat $GIT_DEFAULT_NAME)` read the actual secret value

## Security Benefits

- Secrets are never stored in plaintext in the Nix store
- Each secret is only accessible to its designated owner
- The age key itself can be protected with a passphrase
- Encrypted secrets can be safely committed to version control

## Setup Instructions

1. Install required tools:
   ```bash
   nix-shell -p sops age
   ```

2. Run the `setup-age-key.sh` script to generate your age key:
   ```bash
   ./nixos-secrets/setup-age-key.sh
   ```

3. Update the `.sops.yaml` file with your public key:
   ```yaml
   creation_rules:
     - path_regex: common/.*\.yaml$
       age: >-
         age1abcdefghijklmnopqrstuvwxyz0123456789
     - path_regex: hosts/desktop/.*\.yaml$
       age: >-
         age1abcdefghijklmnopqrstuvwxyz0123456789
     - path_regex: hosts/laptop/.*\.yaml$
       age: >-
         age1abcdefghijklmnopqrstuvwxyz0123456789
   ```

4. Add your secrets to the appropriate YAML files:
   - Host-specific secrets in `hosts/[hostname]/secrets.yaml`:
     ```yaml
     git:
       default_name: "Your Name"
       default_email: "your.email@example.com"
       signing_key: "ABCDEF1234567890"
       work_name: "Your Work Name"
       work_email: "your.work@company.com"
       personal_name: "Your Personal Name"
       personal_email: "your.personal@example.com"
     ```
   - Shared secrets in `common/secrets.yaml`:
     ```yaml
     api_keys:
       github: "github_pat_12345..."
       openai: "sk-abcdef1234567890"
     ```

5. Encrypt your secrets:
   ```bash
   ./nixos-secrets/encrypt-secrets.sh
   ```

6. Commit and push the encrypted secrets

## Available Secrets

The following secrets are currently defined in the system:

### Git Configuration
- `git/default_name`: Default Git username
- `git/default_email`: Default Git email address
- `git/signing_key`: GPG key ID for signing commits
- `git/work_name`: Git username for work repositories
- `git/work_email`: Git email for work repositories
- `git/personal_name`: Git username for personal repositories
- `git/personal_email`: Git email for personal repositories

### API Keys
- `api_keys/github`: GitHub Personal Access Token
- `api_keys/openai`: OpenAI API Key

## Adding New Secrets

To add a new secret:

1. Add it to the appropriate secrets.yaml file (common or host-specific)
2. Encrypt the file using `./nixos-secrets/encrypt-secrets.sh`
3. Add it to the `modules/secrets.nix` file:
   ```nix
   sops.secrets = {
     # Existing secrets...
     
     "new_category/new_secret" = {
       owner = "dev";
       # If it's in common/secrets.yaml:
       sopsFile = ../nixos-secrets/common/secrets.yaml;
     };
   };
   
   # Make it available as an environment variable if needed
   environment.sessionVariables = {
     # Existing variables...
     NEW_SECRET_VAR = config.sops.secrets."new_category/new_secret".path;
   };
   ```
4. Use it in your configuration:
   ```nix
   some_config = "$(cat $NEW_SECRET_VAR 2>/dev/null || echo 'default')";
   ```

## Best Practices

1. **Never commit unencrypted secrets**: Always encrypt with SOPS before committing
2. **Keep your keys secure**: Backup your age key securely
3. **Use different keys for different environments**: Consider using different keys for different machines
4. **Rotate secrets periodically**: Update your secrets on a regular schedule
5. **Limit secret access**: Configure the `owner` parameter for each secret appropriately

This design nicely separates configuration from secrets and allows you to manage a single configuration across multiple machines, each with their own specific credentials and settings.