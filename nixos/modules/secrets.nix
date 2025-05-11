{config, lib, pkgs, ...}:

let
  # Get the hostname to determine which host-specific secrets to use
  hostname = config.networking.hostName;
  username = config.users.defaultUserName;
in
{
  # Ensure sops, age, and related tools are installed
  environment.systemPackages = with pkgs; [
    sops
    age
    ssh-to-age
  ];
  # Configure SOPS (Secrets OPerationS)
  sops = {
    # Default age key locations
    age = {
      keyFile = "/home/${username}/.config/sops/age/keys.txt";
      # Add SSH keys for age encryption - the ed25519 key is used as a fallback
      sshKeyPaths = [
        "/home/${username}/.ssh/id_ed25519"
      ];
    };
    
    # Add the security key to the .sops.yaml file in your nixos-secrets directory
    # In nixos-secrets/.sops.yaml add something like:
    # creation_rules:
    #   - path_regex: .*
    #     key_groups:
    #       - age:
    #           - age1y3ysrwdnhvxtavfsxarr4l7qnweqcc0ttkhkfk3qpcavkzs73fnqlfwfp7
    
    # Host-specific secrets file from the private submodule
    # Use "desktop" as fallback since we know it exists
    defaultSopsFile = ../nixos-secrets/hosts/desktop/secrets.yaml;
    
    # Secrets for Git configuration
    secrets = {
      # Git configuration secrets from host-specific file
      "git/default_name" = {
        owner = username;
      };
      "git/default_email" = {
        owner = username;
      };
      "git/signing_key" = {
        owner = username;
      };
      "git/work_name" = {
        owner = username;
      };
      "git/work_email" = {
        owner = username;
      };
      "git/personal_name" = {
        owner = username;
      };
      "git/personal_email" = {
        owner = username;
      };
      
      # API keys from common secrets file (shared across all hosts)
      "api_keys/github" = {
        owner = username;
        sopsFile = ../nixos-secrets/common/secrets.yaml;
      };
      "api_keys/openai" = {
        owner = username;
        sopsFile = ../nixos-secrets/common/secrets.yaml;
      };
    };
  };
  
  # Make secrets available to home-manager by aliasing them to environment variables
  # This allows the config to be generic while the secrets are host-specific
  environment.sessionVariables = lib.mkIf (config.sops.secrets ? "git/default_name") {
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