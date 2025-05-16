{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # AWS tools
    aws-sam-cli
    awscli2
    ssm-session-manager-plugin
    cargo-lambda
    
    # Other cloud tools
    firebase-tools
  ];
}