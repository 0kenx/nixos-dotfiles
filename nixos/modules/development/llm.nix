{ pkgs, pkgs-unstable, config, inputs, system, ... }:

{
  # Claude and cloud-based LLM tools
  environment.systemPackages = [
    pkgs.aichat
    pkgs.aider-chat
    pkgs-unstable.claude-code
    inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
  ];
}