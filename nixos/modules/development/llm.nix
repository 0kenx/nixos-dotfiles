{ pkgs, pkgs-unstable, config, inputs, system, ... }:

{
  # Claude and cloud-based LLM tools
  environment.systemPackages = [
    pkgs.aichat
    pkgs.aider-chat
    pkgs-unstable.claude-code
    # Claude Desktop temporarily disabled due to upstream version mismatch bug
    # The package extracts AnthropicClaude-0.12.49-full.nupkg but looks for 0.12.29
    # inputs.claude-desktop.packages.${system}.claude-desktop-with-fhs
  ];
}