{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # AWS tools
    # aws-sam-cli  # Temporarily disabled - dependency version conflicts in nixpkgs 25.11
    awscli2
    ssm-session-manager-plugin
    cargo-lambda
    
    # Other cloud tools
    firebase-tools
  ];
}