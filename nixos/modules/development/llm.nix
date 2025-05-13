{ pkgs, pkgs-unstable, config, ... }:

{
  # Claude and cloud-based LLM tools
  environment.systemPackages = [
    pkgs.aichat
    pkgs.aider-chat
    pkgs-unstable.claude-code
  ];
}