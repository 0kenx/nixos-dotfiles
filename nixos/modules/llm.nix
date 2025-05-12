{ pkgs, pkgs-unstable, config, ... }:

{
  # Cloud LLM clients and CLI tools
  environment.systemPackages = [
    pkgs.aichat
    pkgs.aider-chat
    pkgs-unstable.claude-code
  ];
}