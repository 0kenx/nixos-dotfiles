# Managing Secrets in a Private GitHub Repository

This guide explains how to set up a private GitHub repository for your secrets and integrate it as a Git submodule in your public NixOS configuration.

## Setup Overview

1. Create a private GitHub repository for secrets
2. Add the private repository as a Git submodule
3. Configure sops-nix to use the secrets from the submodule
4. Set up `.gitignore` to prevent accidentally committing raw secrets

## Step 1: Create a Private GitHub Repository

1. Create a new private repository on GitHub (e.g., `github.com/0kenx/nixos-secrets`)
2. Initialize the repository structure:

```bash
mkdir -p ~/nixos-secrets/secrets
touch ~/nixos-secrets/secrets/.gitkeep
cd ~/nixos-secrets
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin git@github.com:0kenx/nixos-secrets.git
git push -u origin main
```

## Step 2: Add as a Git Submodule to Your NixOS Configuration

```bash
cd /home/dev/git/nixos-dotfiles/nixos
git submodule add git@github.com:0kenx/nixos-secrets.git nixos-secrets
git commit -m "Add nixos-secrets as a submodule"
```

## Step 3: Set Up Your Secrets Directory Structure

Create the following structure in your private repository:

```
nixos-secrets/
├── hosts/              # Host-specific secrets
│   ├── desktop/        # Desktop-specific secrets
│   │   └── secrets.yaml
│   └── laptop/         # Laptop-specific secrets
│       └── secrets.yaml
├── common/             # Shared secrets across all hosts
│   └── secrets.yaml
└── .sops.yaml          # SOPS configuration
```

## Step 4: Configure SOPS

Create a `.sops.yaml` file in your private repository:

```yaml
# nixos-secrets/.sops.yaml
creation_rules:
  - path_regex: common/.*\.yaml$
    age: >-
      YOUR_AGE_PUBLIC_KEY
  - path_regex: hosts/desktop/.*\.yaml$
    age: >-
      DESKTOP_AGE_PUBLIC_KEY
  - path_regex: hosts/laptop/.*\.yaml$
    age: >-
      LAPTOP_AGE_PUBLIC_KEY
```

## Step 5: Create Example Secrets Files

### Common Secrets

Create and encrypt common secrets:

```bash
# nixos-secrets/common/secrets.yaml
api_keys:
  github: github_token_value
  openai: openai_api_key_value

# Encrypt with SOPS
sops -e -i nixos-secrets/common/secrets.yaml
```

### Host-Specific Secrets

Create and encrypt host-specific secrets:

```bash
# nixos-secrets/hosts/desktop/secrets.yaml
git:
  default_name: Your Desktop Name
  default_email: your.desktop@example.com
  signing_key: DESKTOP_GPG_KEY_ID
  work_name: Your Work Name
  work_email: your.work.email@company.com
  personal_name: Your Personal Name
  personal_email: your.personal.email@example.com

# Encrypt with SOPS
sops -e -i nixos-secrets/hosts/desktop/secrets.yaml
```

## Step 6: Update NixOS Secret Module

Modify your `modules/secrets.nix` to use the submodule:

```nix
{config, lib, pkgs, ...}:

let
  # Get the hostname to determine which host-specific secrets to use
  hostname = config.networking.hostName;
in
{
  # Configure SOPS (Secrets OPerationS)
  sops = {
    # Default age key locations
    age.keyFile = "/home/dev/.config/sops/age/keys.txt";
    
    # Host-specific secrets file
    defaultSopsFile = ../secrets-private/hosts/${hostname}/secrets.yaml;
    
    # Common secrets file
    sopsFiles = [
      ../secrets-private/common/secrets.yaml
    ];
    
    # Secrets for Git configuration
    secrets = {
      # Git configuration secrets from host-specific file
      "git/default_name" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      "git/default_email" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      "git/signing_key" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      "git/work_name" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      "git/work_email" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      "git/personal_name" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      "git/personal_email" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      
      # API keys from common secrets file
      "api_keys/github" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
        path = config.sops.secrets."api_keys/github".path;
      };
      "api_keys/openai" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
        path = config.sops.secrets."api_keys/openai".path;
      };
    };
  };
  
  # Make secrets available to home-manager through environment variables
  environment.sessionVariables = {
    GIT_DEFAULT_NAME = config.sops.secrets."git/default_name".path;
    GIT_DEFAULT_EMAIL = config.sops.secrets."git/default_email".path;
    GIT_SIGNING_KEY = config.sops.secrets."git/signing_key".path;
    GIT_WORK_NAME = config.sops.secrets."git/work_name".path;
    GIT_WORK_EMAIL = config.sops.secrets."git/work_email".path;
    GIT_PERSONAL_NAME = config.sops.secrets."git/personal_name".path;
    GIT_PERSONAL_EMAIL = config.sops.secrets."git/personal_email".path;
    GITHUB_TOKEN = config.sops.secrets."api_keys/github".path;
    OPENAI_API_KEY = config.sops.secrets."api_keys/openai".path;
  };
}
```

## Step 7: Update Your NixOS Flake

Add the submodule path to your flake inputs:

```nix
{
  inputs = {
    # ...existing inputs
    secrets = {
      url = "git+file:./secrets-private";
      flake = false;
    };
  };
  
  # ...
}
```

## Step 8: Working with Submodules

When cloning your repository on a new machine:

```bash
git clone --recurse-submodules https://github.com/0kenx/nixos-dotfiles.git
```

Or if you've already cloned without submodules:

```bash
git submodule update --init --recursive
```

To update the submodule to the latest version:

```bash
cd secrets-private
git pull origin main
cd ..
git add secrets-private
git commit -m "Update secrets submodule"
```

## Security Considerations

1. **Keep your private repository truly private**
2. **Never push unencrypted secrets** even to the private repository
3. **Use different age keys for different machines** for better isolation
4. **Regularly rotate your secrets** and update the encrypted files
5. **Limit access to your private repository** to only trusted individuals

## Adding New Secrets

1. Add the secret to the appropriate YAML file in your private repository
2. Encrypt it with SOPS
3. Update your `secrets.nix` module to expose the new secret
4. Push the changes to your private repository
5. Update the submodule reference in your main repository