# Secret Management with sops-nix

This configuration uses [sops-nix](https://github.com/Mic92/sops-nix) for managing secrets. SOPS (Secrets OPerationS) allows encrypting secrets that can be safely committed to your Git repository.

## Setting Up SOPS

### 1. Install SOPS

```bash
nix-shell -p sops age
```

### 2. Generate Age Key for Encryption

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
```

### 3. Create a .sops.yaml file in the repository root

```bash
cat > ~/.config/sops/.sops.yaml <<EOF
creation_rules:
  - path_regex: secrets/.*\.yaml$
    age: >-
      YOUR_AGE_PUBLIC_KEY
EOF
```

Replace `YOUR_AGE_PUBLIC_KEY` with the public key from your age keys file (the line starting with `# public key: age...`).

## Creating Your Secrets File

1. Copy the example secrets file:

```bash
cp secrets/secrets.yaml.example secrets/secrets.yaml
```

2. Edit the file to include your actual secrets:

```bash
# Edit the unencrypted file first
nano secrets/secrets.yaml
```

3. Encrypt the file:

```bash
sops -e -i secrets/secrets.yaml
```

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

## How Secrets Are Used

The secrets are made available to the system via environment variables pointing to the decrypted secret files:

- `GIT_DEFAULT_NAME`: Points to the decrypted default Git name
- `GIT_DEFAULT_EMAIL`: Points to the decrypted default Git email
- `GIT_SIGNING_KEY`: Points to the decrypted GPG signing key
- ...etc.

## Adding New Secrets

To add a new secret:

1. Add it to the `secrets.yaml` file:

```yaml
new_secret_category:
  new_secret_name: secret_value
```

2. Encrypt the file again:

```bash
sops -e -i secrets/secrets.yaml
```

3. Add it to the `modules/secrets.nix` file:

```nix
sops.secrets = {
  # Existing secrets...
  
  "new_secret_category/new_secret_name" = {
    owner = config.users.users.${config.users.defaultUserName}.name;
  };
};

# Make it available as an environment variable if needed
environment.sessionVariables = {
  # Existing variables...
  NEW_SECRET_VAR = config.sops.secrets."new_secret_category/new_secret_name".path;
};
```

4. Use it in your configuration:

```nix
some_config = "$(cat $NEW_SECRET_VAR)";
```

## Best Practices

1. **Never commit unencrypted secrets**: Always encrypt with SOPS before committing
2. **Keep your keys secure**: Backup your age key securely
3. **Use different keys for different environments**: Consider using different keys for different machines
4. **Rotate secrets periodically**: Update your secrets on a regular schedule
5. **Limit secret access**: Configure the `owner` and `mode` settings for each secret appropriately