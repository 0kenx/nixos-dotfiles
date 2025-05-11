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
    
    # Host-specific secrets file from the private submodule
    defaultSopsFile = ../../nixos-secrets/hosts/${hostname}/secrets.yaml;
    
    # Common secrets file shared across all hosts
    sopsFiles = [
      ../../nixos-secrets/common/secrets.yaml
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
      
      # API keys from common secrets file (shared across all hosts)
      "api_keys/github" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
      "api_keys/openai" = {
        owner = config.users.users.${config.users.defaultUserName}.name;
      };
    };
  };
  
  # Make secrets available to home-manager by aliasing them to environment variables
  # This allows the config to be generic while the secrets are host-specific
  environment.sessionVariables = {
    # Git configuration
    GIT_DEFAULT_NAME = config.sops.secrets."git/default_name".path;
    GIT_DEFAULT_EMAIL = config.sops.secrets."git/default_email".path;
    GIT_SIGNING_KEY = config.sops.secrets."git/signing_key".path;
    GIT_WORK_NAME = config.sops.secrets."git/work_name".path;
    GIT_WORK_EMAIL = config.sops.secrets."git/work_email".path;
    GIT_PERSONAL_NAME = config.sops.secrets."git/personal_name".path;
    GIT_PERSONAL_EMAIL = config.sops.secrets."git/personal_email".path;
    
    # API keys
    GITHUB_TOKEN = config.sops.secrets."api_keys/github".path;
    OPENAI_API_KEY = config.sops.secrets."api_keys/openai".path;
  };
}